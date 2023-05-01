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
            .toObject();
    }

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return AccountSelector.query
            .whereAre(SOQL.Filter.id().isIn(accountIds))
            .toList();
    }

    public static List<AggregateResult> getUniqueAccountNameAmount() {
        return AccountSelector.query
            .count(Account.Name, 'names')
            .toAggregated();
    }

    public static Integer countAccounts() {
        return AccountSelector.query
            .count()
            .toInteger();
    }

    public static Map<Id, SObject> getAccountMap() {
        return AccountSelector.query
            .toMap();
    }

    public static Database.QueryLocator getAccountQueryLocator() {
        return AccountSelector.query
            .toQueryLocator();
    }
}
```
