---
sidebar_position: 10
---

# OFFSET

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

    public static List<Account> getAccountsWithOffset(Integer startingRow) {
        /*
        SELECT Id, Name
        FROM Account
        OFFSET startingRow
        */
        return AccountSelector.Query
            .offset(startingRow)
            .asList();
    }
}
```
