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
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithOffset() {
        return SOQL_Account.query().offset(1000).toList();
    }
}
```
