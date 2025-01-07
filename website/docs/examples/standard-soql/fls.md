---
sidebar_position: 11
---

# FIELD-LEVEL SECURITY

Enforce or bypass FLS.

`USER_MODE` is a default option. You can set `SYSTEM_MODE` for all queries by adding `.systemMode()` to selector class.

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Id, Account.Name)
            .systemMode(); //default FLS mode
    }
}

public with sharing class MyController {
    public static List<Account> getAccountInSystemMode() {
        return SOQL_Account.query().toList();
    }
}
```

More about Field-Level Security you can find in [here](../../advanced-usage/fls.md).
