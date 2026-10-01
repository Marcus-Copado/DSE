/**
 * AccountScoreCalculatorTest
 *
 * Test class for AccountScoreCalculator.
 * Covers: happy path (bulk), edge cases (null / empty input),
 *         single-account convenience method, zero-score scenario,
 *         rating bonus logic (Account.Rating__c), and closed opp exclusion.
 *
 * WEBINAR USAGE:
 *   Part 1-3  : Supports the dependency demo — Rating__c field is exercised
 *               in testCalculateScore_HotRating_IncludesBonus and
 *               testCalculateScore_WarmRating_IncludesBonus.
 *   Part 4-6  : Demonstrates Add vs Retrieve Only commit operations and
 *               quality gate behavior.
 *
 * Commit this class with Git Operation = Add (NOT Retrieve Only).
 * Both this class and AccountScoreCalculator must be in the same user story.
 *
 * Coverage target: >= 80% (Copado quality gate default threshold).
 *
 * @author  Copado Webinar Demo
 * @version 2.0
 */
@IsTest(SeeAllData=false)
private class AccountScoreCalculatorTest {

    // -----------------------------------------------------------------------
    // Test Data Factory
    // -----------------------------------------------------------------------

    /**
     * Creates a test Account with the given name and Rating__c value.
     */
    private static Account createAccount(String name, String rating) {
        Account acc = new Account(
            Name      = name,
            Rating__c = rating
        );
        insert acc;
        return acc;
    }

    /**
     * Creates n Contacts linked to the given Account.
     */
    private static void createContacts(Id accountId, Integer count) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(
                LastName  = 'TestContact' + i,
                AccountId = accountId
            ));
        }
        insert contacts;
    }

    /**
     * Creates n open Opportunities linked to the given Account.
     */
    private static void createOpportunities(Id accountId, Integer count) {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            opps.add(new Opportunity(
                Name      = 'TestOpp' + i,
                AccountId = accountId,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        insert opps;
    }

    // -----------------------------------------------------------------------
    // Test Methods — Rating__c Bonus (supports Parts 1-3 dependency demo)
    // -----------------------------------------------------------------------

    /**
     * Hot rating: bonus = 50
     * Score = 50 (rating) + (1 contact * 10) + (1 opp * 25) = 85
     */
    @IsTest
    static void testCalculateScore_HotRating_IncludesBonus() {
        Account acc = createAccount('Hot Account', 'Hot');
        createContacts(acc.Id, 1);
        createOpportunities(acc.Id, 1);

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(85, score,
            'Hot rating should add 50 bonus: 50 + (1x10) + (1x25) = 85.');
    }

    /**
     * Warm rating: bonus = 25
     * Score = 25 (rating) + (2 contacts * 10) = 45
     */
    @IsTest
    static void testCalculateScore_WarmRating_IncludesBonus() {
        Account acc = createAccount('Warm Account', 'Warm');
        createContacts(acc.Id, 2);

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(45, score,
            'Warm rating should add 25 bonus: 25 + (2x10) = 45.');
    }

    /**
     * Cold rating: bonus = 0
     * Score = 0 (rating) + (1 opp * 25) = 25
     */
    @IsTest
    static void testCalculateScore_ColdRating_NoBonus() {
        Account acc = createAccount('Cold Account', 'Cold');
        createOpportunities(acc.Id, 1);

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(25, score,
            'Cold rating should add 0 bonus: 0 + (1x25) = 25.');
    }

    /**
     * Unknown rating value: bonus = 0 (falls through to default).
     */
    @IsTest
    static void testCalculateScore_UnknownRating_NoBonus() {
        Account acc = createAccount('Unknown Rating Account', 'Lukewarm');

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(0, score,
            'An unrecognised rating value should contribute 0 bonus.');
    }

    // -----------------------------------------------------------------------
    // Test Methods — Core Scoring Logic
    // -----------------------------------------------------------------------

    /**
     * Happy path: single account with contacts and opportunities (no rating).
     * Score = (2 contacts * 10) + (3 opps * 25) = 20 + 75 = 95
     */
    @IsTest
    static void testCalculateScore_SingleAccount_WithContactsAndOpps() {
        Account acc = createAccount('Webinar Demo Corp', null);
        createContacts(acc.Id, 2);
        createOpportunities(acc.Id, 3);

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(95, score,
            'Score should be 95: (2 contacts x 10) + (3 opps x 25).');
    }

    /**
     * Bulk scenario: multiple accounts scored in a single call.
     * Verifies bulkification — no SOQL in loops.
     */
    @IsTest
    static void testCalculateScores_BulkAccounts() {
        Account acc1 = createAccount('Bulk Account One', 'Hot');
        Account acc2 = createAccount('Bulk Account Two', null);

        createContacts(acc1.Id, 1);       // 1 * 10 = 10
        createOpportunities(acc1.Id, 2);  // 2 * 25 = 50  + 50 (Hot) => acc1 = 110

        createContacts(acc2.Id, 3);       // 3 * 10 = 30
        createOpportunities(acc2.Id, 0);  //           0  => acc2 = 30

        Set<Id> accountIds = new Set<Id>{ acc1.Id, acc2.Id };

        Test.startTest();
            Map<Id, Integer> scores = AccountScoreCalculator.calculateScores(accountIds);
        Test.stopTest();

        System.assertEquals(2, scores.size(), 'Both accounts should be in the result map.');
        System.assertEquals(110, scores.get(acc1.Id), 'Account 1 score should be 110.');
        System.assertEquals(30,  scores.get(acc2.Id), 'Account 2 score should be 30.');
    }

    /**
     * Edge case: account with no contacts, no opportunities, and no rating scores 0.
     */
    @IsTest
    static void testCalculateScore_NoRelatedRecords_ReturnsZero() {
        Account acc = createAccount('Empty Account', null);

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(0, score,
            'An account with no contacts, opportunities, or rating should score 0.');
    }

    /**
     * Edge case: null Id passed to single-account method returns 0.
     */
    @IsTest
    static void testCalculateScore_NullId_ReturnsZero() {
        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(null);
        Test.stopTest();

        System.assertEquals(0, score, 'Null Id should return a score of 0.');
    }

    /**
     * Edge case: null set passed to bulk method returns empty map.
     */
    @IsTest
    static void testCalculateScores_NullSet_ReturnsEmptyMap() {
        Test.startTest();
            Map<Id, Integer> scores = AccountScoreCalculator.calculateScores(null);
        Test.stopTest();

        System.assertNotEquals(null, scores, 'Result map should never be null.');
        System.assertEquals(0, scores.size(), 'Result map should be empty for null input.');
    }

    /**
     * Edge case: empty set passed to bulk method returns empty map.
     */
    @IsTest
    static void testCalculateScores_EmptySet_ReturnsEmptyMap() {
        Test.startTest();
            Map<Id, Integer> scores = AccountScoreCalculator.calculateScores(new Set<Id>());
        Test.stopTest();

        System.assertNotEquals(null, scores, 'Result map should never be null.');
        System.assertEquals(0, scores.size(), 'Result map should be empty for empty input.');
    }

    /**
     * Verifies that closed Opportunities are NOT counted in the score.
     * Only open (IsClosed = false) opportunities contribute to the score.
     */
    @IsTest
    static void testCalculateScore_ClosedOppsNotCounted() {
        Account acc = createAccount('Closed Opp Account', null);

        Opportunity closedOpp = new Opportunity(
            Name      = 'Closed Won Opp',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-10)
        );
        insert closedOpp;

        // 1 contact = 10 points; 0 open opps = 0 points => total 10
        createContacts(acc.Id, 1);

        Test.startTest();
            Integer score = AccountScoreCalculator.calculateScore(acc.Id);
        Test.stopTest();

        System.assertEquals(10, score,
            'Closed opportunities should not contribute to the score.');
    }

    /**
     * Directly tests the private getRatingBonus method via @TestVisible.
     * Blank/null rating should return 0.
     */
    @IsTest
    static void testGetRatingBonus_BlankRating_ReturnsZero() {
        Test.startTest();
            Integer bonus = AccountScoreCalculator.getRatingBonus('');
        Test.stopTest();

        System.assertEquals(0, bonus, 'Blank rating should return 0 bonus.');
    }
}