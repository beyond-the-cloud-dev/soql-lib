---
sidebar_position: 11
---

# Field Level Security

Enforce or bypass FLS.

`USER_MODE` is a default option. You can set `SYSTEM_MODE` for all queries by adding `.systemMode()` to selector class.

```apex
public inherited sharing class AccountSelector {

    public static SOQL query {
        get {
            return SOQL.of(Account.SObjectType)
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                })
                .systemMode(); //default FLS mode
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountInSystemMode() {
        return AccountSelector.query
            .userMode() //override selector FLS mode
            .toList();
    }
}
```
