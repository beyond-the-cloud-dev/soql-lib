---
sidebar_position: 6
---

# WHERE

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

    public static List<Account> getByIdOrName(Id accountId, String accountName) {
        /*
        SELECT Id, Name
        FROM Account
        WHERE Id = :accountId OR Name LIKE :'%' + accountName + '%'
        */
        return AccountSelector.Query
                .whereAre(SOQL.FiltersGroup
                    .add(SOQL.Filter.with(Account.Id).equal(accountId))
                    .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                    .conditionLogic('1 OR 2')
                )
                .asList();
    }
}
```
