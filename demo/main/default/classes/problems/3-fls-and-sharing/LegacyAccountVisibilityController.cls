public with sharing class LegacyAccountVisibilityController {
    public List<Account> getAccounts() {
        return [SELECT Id, Name, AnnualRevenue FROM Account WITH USER_MODE];
    }

    public List<Account> getAccountsWithoutSharing() {
        return new WithoutSharing().getAccounts();
    }

    public List<Account> getReadableAccountsWithoutSharing() {
        return Security.stripInaccessible(AccessType.READABLE, new WithoutSharing().getAccounts()).getRecords();
    }

    public without sharing class WithoutSharing {
        public List<Account> getAccounts() {
            return [SELECT Id, Name, AnnualRevenue FROM Account WITH SYSTEM_MODE];
        }
    }
}
