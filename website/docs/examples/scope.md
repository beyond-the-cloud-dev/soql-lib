---
sidebar_position: 5
---

# USING SCOPE

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

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getMineAccounts() {
        return AccountSelector.Query
            .mineScope()
            .asList();
    }

    public static List<Account> getTeamAccounts() {
        return AccountSelector.Query
            .myTeamScope()
            .asList();
    }
}
```
