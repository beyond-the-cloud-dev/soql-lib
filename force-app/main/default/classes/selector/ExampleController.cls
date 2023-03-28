public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return AccountSelector.Query
            .field(Account.BillingCity)
            .field(Account.BillingCountry)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.field(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.field(Account.Name).likeAny(accountName))
            )
            .asList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.getByRecordType(recordType)
                .field(Account.ParentId)
                .asList();
    }
}
