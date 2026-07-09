@IsTest
private class ContactDefaultsTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact c = new Contact(
            FirstName = 'Debbie',
            LastName  = 'Test',
            AccountId = acc.Id
        );
        insert c;
    }

    @IsTest
    static void testSetDefaultLeadSource() {
        Contact c = [SELECT Id, LeadSource FROM Contact LIMIT 1];
        c.LeadSource = null;

        Test.startTest();
        ContactDefaults.setDefaultLeadSource(c);
        Test.stopTest();

        System.assertEquals('Partner Referral', c.LeadSource,
            'LeadSource should default to Partner Referral.');
    }

    @IsTest
    static void testSetDefaultDepartment() {
        Contact c = [SELECT Id, Department FROM Contact LIMIT 1];
        c.Department = null;

        Test.startTest();
        ContactDefaults.setDefaultDepartment(c);
        Test.stopTest();

        System.assertEquals('Sales', c.Department,
            'Department should default to Sales.');
    }

    @IsTest
    static void testSetDefaultDescription() {
        Contact c = [SELECT Id, Description FROM Contact LIMIT 1];
        c.Description = null;

        Test.startTest();
        ContactDefaults.setDefaultDescription(c);
        Test.stopTest();

        System.assertEquals('Contact sourced via partner channel.', c.Description,
            'Description should be set to the partner channel default.');
    }

    @IsTest
    static void testSetDefaultTitle() {
        Contact c = [SELECT Id, Title FROM Contact LIMIT 1];
        c.Title = null;

        Test.startTest();
        ContactDefaults.setDefaultTitle(c);
        Test.stopTest();

        System.assertEquals('Stakeholder', c.Title,
            'Title should default to Stakeholder.');
    }

    @IsTest
    static void testApplyDefaults_bulk() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(
                FirstName   = 'Bulk',
                LastName    = 'Contact ' + i,
                LeadSource  = null,
                Department  = null,
                Description = null,
                Title       = null
            ));
        }

        Test.startTest();
        List<Contact> results = ContactDefaults.applyDefaults(contacts);
        Test.stopTest();

        for (Contact c : results) {
            System.assertEquals('Partner Referral', c.LeadSource,  'LeadSource should be Partner Referral.');
            System.assertEquals('Sales',            c.Department,  'Department should be Sales.');
            System.assertNotEquals(null,            c.Description, 'Description should not be null.');
            System.assertEquals('Stakeholder',      c.Title,       'Title should be Stakeholder.');
        }
    }

    @IsTest
    static void testExistingValueNotOverwritten() {
        Contact c = new Contact(
            FirstName   = 'Existing',
            LastName    = 'Values',
            LeadSource  = 'Phone',
            Department  = 'Engineering',
            Description = 'Already set.',
            Title       = 'Director'
        );

        Test.startTest();
        ContactDefaults.applyDefaults(new List<Contact>{ c });
        Test.stopTest();

        System.assertEquals('Phone',       c.LeadSource,  'LeadSource should not be overwritten.');
        System.assertEquals('Engineering', c.Department,  'Department should not be overwritten.');
        System.assertEquals('Already set.', c.Description,'Description should not be overwritten.');
        System.assertEquals('Director',    c.Title,       'Title should not be overwritten.');
    }
}