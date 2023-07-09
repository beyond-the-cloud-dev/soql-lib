---
sidebar_position: 11
---

# Field Level Security

Enforce or bypass FLS.

`USER_MODE` is a default option. You can set `SYSTEM_MODE` for all queries by adding `.systemMode()` to selector class.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .systemMode(); //default FLS mode
    }
}

public with sharing class MyController {

    public static List<Account> getAccountInSystemMode() {
        return SOQL_Account.query().userMode().toList(); //override selector FLS mode
    }
}
```
