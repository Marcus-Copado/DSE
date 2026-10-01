/**
 * AccountScoreCalculator
 *
 * Calculates a simple engagement score for an Account based on
 * the number of related Contacts, open Opportunities, and the
 * custom field Account.Rating__c (used in the webinar dependency demo).
 *
 * WEBINAR SETUP — VERSION 1:
 *   Commit this version with Git Operation = Add and promote it all
 *   the way to the target environment BEFORE the demo. This establishes
 *   the baseline that the Selective Commit editor will compare against.
 *
 * @author  Copado Webinar Demo
 * @version 1.0
 */
public with sharing class AccountScoreCalculator {

    // Score weights
    private static final Integer CONTACT_WEIGHT     = 10;
    private static final Integer OPPORTUNITY_WEIGHT = 25;

    // Rating bonus values — references Account.Rating__c (custom field)
    // This dependency is intentional: used in Part 2 (Dependency Analysis demo)
    private static final Map<String, Integer> RATING_BONUS = new Map<String, Integer>{
        'Hot'  => 50,
        'Warm' => 25,
        'Cold' => 0
    };

    /**
     * Calculates engagement scores for a list of Account Ids.
     * Returns a map of Account Id -> score.
     *
     * Score = (contacts * 10) + (open opps * 25) + rating bonus
     *
     * @param accountIds  Set of Account Ids to score
     * @return            Map<Id, Integer> of scores
     */
    public static Map<Id, Integer> calculateScores(Set<Id> accountIds) {

        if (accountIds == null || accountIds.isEmpty()) {
            return new Map<Id, Integer>();
        }

        Map<Id, Integer> scoreByAccountId = new Map<Id, Integer>();

        // Initialise every requested account with a base score of 0
        for (Id accId : accountIds) {
            scoreByAccountId.put(accId, 0);
        }

        // Apply rating bonus from Account.Rating__c — single SOQL query
        // NOTE: Rating__c is the custom field that drives the dependency demo
        for (Account acc : [
            SELECT Id, Rating__c
            FROM   Account
            WHERE  Id IN :accountIds
        ]) {
            Integer bonus = getRatingBonus(acc.Rating__c);
            scoreByAccountId.put(acc.Id, scoreByAccountId.get(acc.Id) + bonus);
        }

        // Count Contacts per Account — single SOQL query (no SOQL in loops)
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) cnt
            FROM   Contact
            WHERE  AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            Id      accId = (Id)      ar.get('AccountId');
            Integer cnt   = (Integer) ar.get('cnt');
            scoreByAccountId.put(accId, scoreByAccountId.get(accId) + (cnt * CONTACT_WEIGHT));
        }

        // Count open Opportunities per Account — single SOQL query
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) cnt
            FROM   Opportunity
            WHERE  AccountId IN :accountIds
            AND    IsClosed   = false
            GROUP BY AccountId
        ]) {
            Id      accId = (Id)      ar.get('AccountId');
            Integer cnt   = (Integer) ar.get('cnt');
            scoreByAccountId.put(accId, scoreByAccountId.get(accId) + (cnt * OPPORTUNITY_WEIGHT));
        }

        return scoreByAccountId;
    }

    /**
     * Convenience method: score a single Account.
     *
     * @param accountId  Single Account Id
     * @return           Integer score (0 if not found)
     */
    public static Integer calculateScore(Id accountId) {
        if (accountId == null) {
            return 0;
        }
        Map<Id, Integer> scores = calculateScores(new Set<Id>{ accountId });
        return scores.containsKey(accountId) ? scores.get(accountId) : 0;
    }

    /**
     * Returns the rating bonus for a given Rating__c value.
     *
     * VERSION 1 — Warm bonus is 25.
     * After promoting this version to the target, change Warm to 30
     * in the source sandbox to create the diff for the Selective Commit demo.
     *
     * @param rating  Value of Account.Rating__c
     * @return        Integer bonus score
     */
    @TestVisible
    private static Integer getRatingBonus(String rating) {
        if (String.isBlank(rating)) {
            return 0;
        }
        return RATING_BONUS.containsKey(rating) ? RATING_BONUS.get(rating) : 0;
    }
}