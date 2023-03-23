---
sidebar_position: 10
---

# OFFSET

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

    public static List<Account> getAccountsWithOffset(Integer startingRow) {
        return (List<Account>) AccountSelector.Query
            .offset(startingRow)
            .asList();
    }
}
```
