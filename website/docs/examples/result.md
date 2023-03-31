---
sidebar_position: 15
---

# Result

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return AccountSelector.Query
            .whereAre(SOQL.Filter.id().isIn(accountIds))
            .asList();
    }

    public static Account getAccountById(Id accountId) {
        return (Account) AccountSelector.Query
            .whereAre(SOQL.Filter.id().equal(accountId))
            .asObject();
    }

    public static Integer countAccounts() {
        return AccountSelector.Query
            .count()
            .asInteger();
    }
}
```
