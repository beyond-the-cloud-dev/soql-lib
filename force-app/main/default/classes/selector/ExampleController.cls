public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .asList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.getByRecordType(recordType)
                .with(Account.ParentId)
                .asList();
    }
}
