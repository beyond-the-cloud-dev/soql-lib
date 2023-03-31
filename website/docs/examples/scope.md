---
sidebar_position: 5
---

# USING SCOPE

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
        /*
        SELECT Id, Name
        FROM Account
        USING SCOPE MINE
        */
        return AccountSelector.Query
            .mineScope()
            .asList();
    }

    public static List<Account> getTeamAccounts() {
        /*
        SELECT Id, Name
        FROM Account
        USING SCOPE TEAM
        */
        return AccountSelector.Query
            .myTeamScope()
            .asList();
    }
}
```
