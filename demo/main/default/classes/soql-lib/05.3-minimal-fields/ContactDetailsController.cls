public with sharing class ContactDetailsController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactDetails(Id accountId) {
        return SOQL_Contact.query()
            .byAccountId(accountId)
            .with(Contact.Email, Contact.Phone, Contact.Department, Contact.Title)
            .with('Account', Account.Name, Account.Industry)
            .toList();
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getBasicContacts(Id accountId) {
        return SOQL_Contact.query()
            .byAccountId(accountId)
            .toList();
    }
}
