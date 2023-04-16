---
sidebar_position: 6
---

# WHERE

The condition expression.

```sql
SELECT Id, Name
FROM Account
WHERE Id = :accountId OR Name LIKE :'%' + accountName + '%'
```
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

    public static List<Account> getByIdOrName(Id accountId, String accountName) {
        return AccountSelector.query
                .whereAre(SOQL.FiltersGroup
                    .add(SOQL.Filter.id().equal(accountId))
                    .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                    .conditionLogic('1 OR 2')
                )
                .asList();
    }
}
```
