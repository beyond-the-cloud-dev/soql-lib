public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query()
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
