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
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithOffset() {
        return AccountSelector.query()
            .offset(1000)
            .toList();
    }
}
```
