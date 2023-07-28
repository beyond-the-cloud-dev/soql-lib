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

    public static List<Account> getMineAccounts() {
        return SOQL_Account.query()
            .mineScope()
            .toList();
    }

    public static List<Account> getTeamAccounts() {
        return SOQL_Account.query()
            .myTeamScope()
            .toList();
    }
}
```
