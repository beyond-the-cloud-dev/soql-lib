public with sharing class ExampleController {

    @AuraEnabled
    public static List<Contact> getContactsByRecordType(String recordType) {
        return SOQL_Contact.query()
            .byRecordType(recordType)
            .with(Contact.Email, Contact.Title)
            .toList();
    }

    @AuraEnabled
    public static List<Contact> getContactsRelatedToAccount(Id accountId) {
        return SOQL_Contact.query().byAccountId(accountId).toList();
    }

    @AuraEnabled
    public static String getContactName(Id contactId) {
        return SOQL_Contact.query().toName(contactId);
    }

    @AuraEnabled
    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL_Account.query()
            .byRecordType('Partner')
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .toList();
    }

    @AuraEnabled
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query()
            .byRecordType(recordType)
            .byIndustry('IT')
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }

    @AuraEnabled
    public static String getAccountIndustry(Id accountId) {
        return SOQL_Account.query().toIndustry(accountId);
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunitiesRelatedToAccount(Id accountId) {
        return SOQL_Opportunity.query().byAccountId(accountId).toList();
    }

    @AuraEnabled
    public static Integer getOpportunityAmount(Id opportunityId) {
        return SOQL_Opportunity.query().toAmount(opportunityId);
    }
}
