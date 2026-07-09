@IsTest
private class ContactDefaultsTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact c = new Contact(
            FirstName = 'Dave',
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

        System.assertEquals('Web', c.LeadSource,
            'LeadSource should default to Web.');
    }

    @IsTest
    static void testSetDefaultDepartment() {
        Contact c = [SELECT Id, Department FROM Contact LIMIT 1];
        c.Department = null;

        Test.startTest();
        ContactDefaults.setDefaultDepartment(c);
        Test.stopTest();

        System.assertEquals('General', c.Department,
            'Department should default to General.');
    }

    @IsTest
    static void testSetDefaultDescription() {
        Contact c = [SELECT Id, Description FROM Contact LIMIT 1];
        c.Description = null;

        Test.startTest();
        ContactDefaults.setDefaultDescription(c);
        Test.stopTest();

        System.assertEquals('New contact added via default automation.', c.Description,
            'Description should be set to the default value.');
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
                Description = null
            ));
        }

        Test.startTest();
        List<Contact> results = ContactDefaults.applyDefaults(contacts);
        Test.stopTest();

        for (Contact c : results) {
            System.assertEquals('Web',     c.LeadSource,  'LeadSource should be Web.');
            System.assertEquals('General', c.Department,  'Department should be General.');
            System.assertNotEquals(null,   c.Description, 'Description should not be null.');
        }
    }

    @IsTest
    static void testExistingValueNotOverwritten() {
        Contact c = new Contact(
            FirstName   = 'Existing',
            LastName    = 'Values',
            LeadSource  = 'Phone',
            Department  = 'Engineering',
            Description = 'Already set.'
        );

        Test.startTest();
        ContactDefaults.applyDefaults(new List<Contact>{ c });
        Test.stopTest();

        System.assertEquals('Phone',       c.LeadSource,  'LeadSource should not be overwritten.');
        System.assertEquals('Engineering', c.Department,  'Department should not be overwritten.');
        System.assertEquals('Already set.', c.Description,'Description should not be overwritten.');
    }
}