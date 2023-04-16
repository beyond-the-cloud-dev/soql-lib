---
sidebar_position: 15
---

# Result

Execut SOQL and get results.

```apex
public inherited sharing class AccountSelector {

    public static SOQL query {
        get {
            return SOQL.of(Account.SObjectType)
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static Account getAccountById(Id accountId) {
        return (Account) AccountSelector.query
            .whereAre(SOQL.Filter.id().equal(accountId))
            .asObject();
    }

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return AccountSelector.query
            .whereAre(SOQL.Filter.id().isIn(accountIds))
            .asList();
    }

    public static List<AggregateResult> getUniqueAccountNameAmount() {
        return AccountSelector.query
            .countAs(Account.Name, 'names')
            .asAggregated();
    }

    public static Integer countAccounts() {
        return AccountSelector.query
            .count()
            .asInteger();
    }

    public static Map<Id, SObject> getAccountMap() {
        return AccountSelector.query
            .asMap();
    }

    public static Database.QueryLocator getAccountQueryLocator() {
        return AccountSelector.query
            .asQueryLocator();
    }
}
```
