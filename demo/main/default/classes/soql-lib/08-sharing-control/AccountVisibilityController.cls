public with sharing class AccountVisibilityController {
    public List<Account> getAccounts() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.AnnualRevenue)
            .toList();
    }

    public List<Account> getAccountsWithoutSharing() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.AnnualRevenue)
            .systemMode()
            .withoutSharing()
            .toList();
    }

    public List<Account> getReadableAccountsWithoutSharing() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.AnnualRevenue)
            .systemMode()
            .withoutSharing()
            .stripInaccessible()
            .toList();
    }
}
