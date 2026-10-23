public with sharing class ChildAccountsService {
    public static List<Account> getChildAccounts(Id parentId) {
        return SOQL_Account.query()
            .byParentId(parentId)
            .toList();
    }

    public static Map<String, List<SObject>> getChildAccountsByIndustry(Id parentId) {
        return SOQL_Account.query()
            .byParentId(parentId)
            .with(Account.Industry)
            .toAggregatedMap(Account.Industry);
    }
}
