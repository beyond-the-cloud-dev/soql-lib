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
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Lead.SObjectType)
                .with(Account.Id, Account.Name, Account.Industry);
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return AccountSelector.query()
                .orderBy(Account.Industry).sortDesc()
                .orderBy(Account.Id)
                .toList();
    }
}
```
