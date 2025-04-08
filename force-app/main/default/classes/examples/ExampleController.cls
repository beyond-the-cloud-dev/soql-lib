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
        return (String) SOQL_Contact.query().byId(contactId).toValueOf(Contact.Name);
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
    public static List<Account> getAccountsByRecordTypeOrITIndustry(String recordType) {
        return SOQL_Account.query()
            .byIndustry('IT')
            .byRecordType(recordType)
            .anyConditionMatching()
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }

    @AuraEnabled
    public static String getAccountIndustry(Id accountId) {
        return (String) SOQL_Account.query().byId(accountId).toValueOf(Account.Industry);
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunitiesRelatedToAccount(Id accountId) {
        return SOQL_Opportunity.query().byAccountId(accountId).toList();
    }

    @AuraEnabled
    public static Integer getOpportunityAmount(Id opportunityId) {
        return (Integer) SOQL_Opportunity.query().byId(opportunityId).toValueOf(Opportunity.Amount);
    }
}
