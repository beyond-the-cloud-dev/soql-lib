public with sharing class AutomaticBindingExamples {
    public static List<Account> previewBostonAccounts(String accountName) {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Boston'))
            .whereAre(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
            .preview()
            .toList();
    }
}
