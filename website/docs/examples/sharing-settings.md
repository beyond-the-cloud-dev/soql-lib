---
sidebar_position: 12
---

# Sharing

Control sharing rules behavior.

`with sharing` is a default option option, because of `USER_MODE`.

You can control sharing rules only in `.systemMode()`.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithSharing() {
        return SOQL_Account.query().systemMode().withSharing().toList();
    }

    public static List<Account> getAccountsWithoutSharing() {
        return SOQL_Account.query().systemMode().withoutSharing().toList();
    }
}
```

More about Sharings you can find in [here](../advanced-usage/sharing.md).
