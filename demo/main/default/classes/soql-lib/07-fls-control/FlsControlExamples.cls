public with sharing class FlsControlExamples {
    public static List<Account> getAccountsInSystemMode() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .systemMode()
            .toList();
    }

    public static List<Account> getReadableAccounts() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .systemMode()
            .stripInaccessible()
            .toList();
    }
}
