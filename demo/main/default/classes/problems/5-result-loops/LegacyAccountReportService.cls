public with sharing class LegacyAccountReportService {
    public static Set<String> getAccountNames() {
        Set<String> accountNames = new Set<String>();
        for (Account account : [SELECT Name FROM Account]) {
            accountNames.add(account.Name);
        }
        return accountNames;
    }

    public static Map<Id, Id> getAccountIdByContactId() {
        Map<Id, Id> accountIdByContactId = new Map<Id, Id>();
        for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
            accountIdByContactId.put(contact.Id, contact.AccountId);
        }
        return accountIdByContactId;
    }
}
