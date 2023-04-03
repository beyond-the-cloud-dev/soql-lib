---
sidebar_position: 8
---

# ORDER BY

```sql
SELECT Id, Name, Industry
FROM Account
ORDER BY Industry DESC NULLS FIRST, Id ASC NULLS FIRST
```
```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Lead.sObjectType)
                 .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name,
                    Account.Industry
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return AccountSelector.Query
                .orderBy(Account.Industry).sortDesc()
                .orderBy(Account.Id)
                .asList();
    }
}
```
