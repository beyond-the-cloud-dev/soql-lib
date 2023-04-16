---
sidebar_position: 9
---

# LIMIT

Specify the maximum number of rows to return.

```sql
SELECT Id, Name
FROM Account
LIMIT 1000
```
```apex
public inherited sharing class AccountSelector {

    public static SQOL Query {
        get {
            return SQOL.of(Account.SObjectType)
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithLimit() {
        return AccountSelector.Query
            .setLimit(1000)
            .asList();
    }
}
```
