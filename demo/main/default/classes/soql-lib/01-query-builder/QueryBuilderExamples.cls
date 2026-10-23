public with sharing class QueryBuilderExamples {
    public static List<Account> getAccounts() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.Industry)
            .toList();
    }

    public static List<Account> getBostonAccounts(String accountName) {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Boston'))
            .whereAre(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
            .toList();
    }
}
