---
sidebar_position: 12
---

# SHARING MODE

Control sharing rules behavior.

`with sharing` is a default option option, because of `USER_MODE`.

You can control sharing rules only in `.systemMode()`.

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsInheritedSharing() {
        return SOQL_Account.query().systemMode().toList();
    }

    public static List<Account> getAccountsWithSharing() {
        return SOQL_Account.query().systemMode().withSharing().toList();
    }

    public static List<Account> getAccountsWithoutSharing() {
        return SOQL_Account.query().systemMode().withoutSharing().toList();
    }
}
```

More about Sharings you can find in [here](../advanced-usage/sharing.md).
