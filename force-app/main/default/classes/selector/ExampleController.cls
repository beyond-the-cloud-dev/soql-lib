public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
