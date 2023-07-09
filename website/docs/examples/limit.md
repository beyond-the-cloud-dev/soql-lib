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
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SQOL query() {
        return SQOL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithLimit() {
        return SOQL_Account.query().setLimit(1000).toList();
    }
}
```
