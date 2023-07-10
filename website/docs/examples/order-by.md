---
sidebar_position: 8
---

# ORDER BY

Control the order of the query results.

```sql
SELECT Id, Name, Industry
FROM Account
ORDER BY Industry DESC NULLS FIRST, Id ASC NULLS FIRST
```
```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.Industry);
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return SOQL_Account.query()
            .orderBy(Account.Industry).sortDesc()
            .orderBy(Account.Id)
            .toList();
    }
}
```
