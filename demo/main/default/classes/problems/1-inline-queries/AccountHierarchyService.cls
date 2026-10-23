public with sharing class AccountHierarchyService {
    public static Map<Id, List<Account>> getChildAccountsByParentId(Set<Id> parentIds) {
        Map<Id, List<Account>> childAccountsByParentId = new Map<Id, List<Account>>();

        for (Account childAccount : [SELECT Id, Name, Industry, ParentId FROM Account WHERE ParentId IN :parentIds]) {
            if (!childAccountsByParentId.containsKey(childAccount.ParentId)) {
                childAccountsByParentId.put(childAccount.ParentId, new List<Account>());
            }
            childAccountsByParentId.get(childAccount.ParentId).add(childAccount);
        }

        return childAccountsByParentId;
    }
}
