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
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query()
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getByIdOrName(Id accountId, String accountName) {
        return AccountSelector.query()
                .whereAre(SOQL.FilterGroup
                    .add(SOQL.Filter.id().equal(accountId))
                    .add(SOQL.Filter.with(Account.Name).contains(accountName))
                    .anyConditionMatching() // OR
                )
                .toList();
    }
}
```
