---
sidebar_position: 5
---

# USING SCOPE

Get records within a specified scope.

```sql
SELECT Id, Name
FROM Account
USING SCOPE MINE

SELECT Id, Name
FROM Account
USING SCOPE TEAM
```
```apex
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getMineAccounts() {
        return AccountSelector.query()
            .mineScope()
            .toList();
    }

    public static List<Account> getTeamAccounts() {
        return AccountSelector.query()
            .myTeamScope()
            .toList();
    }
}
```
