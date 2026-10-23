public with sharing class ChildAccountsController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getChildAccounts(Id accountId) {
        return [SELECT Id, Name FROM Account WHERE ParentId = :accountId];
    }
}
