public with sharing class ContactDefaults {

    /**
     * Sets the Lead Source to 'Partner Referral' if not already populated.
     */
    public static Contact setDefaultLeadSource(Contact c) {
        if (c.LeadSource == null) {
            c.LeadSource = 'Partner Referral';
        }
        return c;
    }

    /**
     * Sets the Department to 'Sales' if not already populated.
     */
    public static Contact setDefaultDepartment(Contact c) {
        if (c.Department == null) {
            c.Department = 'General';
        }
        return c;
    }

    /**
     * Sets a default Description if not already populated.
     */
    public static Contact setDefaultDescription(Contact c) {
        if (c.Description == null) {
            c.Description = 'New contact added via default automation.';
        }
        return c;
    }

    /**
     * Applies all default values to a list of Contacts.
     */
    public static List<Contact> applyDefaults(List<Contact> contacts) {
        for (Contact c : contacts) {
            setDefaultLeadSource(c);
            setDefaultDepartment(c);
            setDefaultDescription(c);
        }
        return contacts;
    }
}