---
sidebar_position: 9
---

# LIMIT

```apex
public inherited sharing class AccountSelector {

    public static SQOL Query {
        get {
            return SQOL.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithLimit(Integer amount) {
        return (List<Account>) AccountSelector.Query
            .setLimit(amount)
            .asList();
    }
}
```
