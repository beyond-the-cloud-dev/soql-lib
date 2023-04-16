---
sidebar_position: 10
---

# OFFSET

Efficient way to handle large results sets.

```sql
SELECT Id, Name
FROM Account
OFFSET 1000
```
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

    public static List<Account> getAccountsWithOffset() {
        return AccountSelector.Query
            .offset(1000)
            .asList();
    }
}
```
