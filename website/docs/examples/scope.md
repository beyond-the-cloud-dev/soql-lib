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
public inherited sharing class AccountSelector {

    public static SOQL query {
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

    public static List<Account> getMineAccounts() {
        return AccountSelector.query
            .mineScope()
            .asList();
    }

    public static List<Account> getTeamAccounts() {
        return AccountSelector.query
            .myTeamScope()
            .asList();
    }
}
```
