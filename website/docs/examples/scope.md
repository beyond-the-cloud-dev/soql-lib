---
sidebar_position: 5
---

# USING SCOPE

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .fields(new List<sObjectField>{
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
