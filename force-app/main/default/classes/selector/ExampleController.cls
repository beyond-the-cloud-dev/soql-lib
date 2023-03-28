public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.Query
            .field(Account.BillingCity)
            .field(Account.BillingCountry)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.field(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .asList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.getByRecordType(recordType)
                .field(Account.ParentId)
                .asList();
    }
}
