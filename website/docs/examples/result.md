---
sidebar_position: 15
---

# Result

Execut SOQL and get results.

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
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
        return (Account) AccountSelector.Query
            .whereAre(SOQL.Filter.id().equal(accountId))
            .asObject();
    }

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return AccountSelector.Query
            .whereAre(SOQL.Filter.id().isIn(accountIds))
            .asList();
    }

    public static List<AggregateResult> getUniqueAccountNameAmount() {
        return AccountSelector.Query
            .countAs(Account.Name, 'names')
            .asAggregated();
    }

    public static Integer countAccounts() {
        return AccountSelector.Query
            .count()
            .asInteger();
    }

    public static Map<Id, SObject> getAccountMap() {
        return AccountSelector.Query
            .asMap();
    }

    public static Database.QueryLocator getAccountQueryLocator() {
        return AccountSelector.Query
            .asQueryLocator();
    }
}
```
