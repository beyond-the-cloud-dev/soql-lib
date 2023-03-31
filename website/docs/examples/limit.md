---
sidebar_position: 9
---

# LIMIT

```apex
public inherited sharing class AccountSelector {

    public static SQOL Query {
        get {
            return SQOL.of(Account.sObjectType)
                .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithLimit(Integer amount) {
        /*
        SELECT Id, Name
        FROM Account
        LIMIT amount
        */
        return AccountSelector.Query
            .setLimit(amount)
            .asList();
    }
}
```
