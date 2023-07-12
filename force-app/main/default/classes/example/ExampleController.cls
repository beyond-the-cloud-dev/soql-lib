public with sharing class ExampleController {

    // With Composition

    @AuraEnabled
    public static List<Contact> getContactsByRecordType(String recordType) {
        return SOQL_Contact.byRecordType(recordType)
            .with(Contact.Email, Contact.Title)
            .toList();
    }

    @AuraEnabled
    public static List<Contact> getContactsRelatedToAccount(Id accountId) {
        return SOQL_Contact.byAccountId(accountId).toList();
    }

    @AuraEnabled
    public static String getContactName(Id contactId) {
        return SOQL_Contact.toName(contactId);
    }

    // With Inheritance

    @AuraEnabled
    public static List<Account> getPartnerAccounts(String accountName) {
        return new SOQL_Account()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .toList();
    }

    @AuraEnabled
    public static List<Account> getAccountsByRecordType(String recordType) {
        return new SOQL_Account()
            .byRecordType(recordType)
            .byIndustry('IT')
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }

    @AuraEnabled
    public static String getAccountIndustry(Id accountId) {
        return new SOQL_Account().toIndustry(accountId);
    }

    // Standard (Old) Approach

    @AuraEnabled
    public static List<Opportunity> getOpportunitiesByRecordType(String recordType) {
        return new SOQL_Opportunity().byRecordType(recordType);
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunitiesRelatedToAccount(Id accountId) {
        return new SOQL_Opportunity().byAccountId(accountId);
    }


    @AuraEnabled
    public static Integer getOpportunityAmount(Id opportunityId) {
        return new SOQL_Opportunity().toAmount(opportunityId);
    }
}
