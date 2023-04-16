---
sidebar_position: 12
---

# Sharing

Control sharing rules behavior.

`with sharing` is a default option option, because of `USER_MODE`.

You can control sharing rules only in `.systemMode()`.

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.SObjectType)
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithSharing() {
        return AccountSelector.Query
            .systemMode()
            .withSharing()
            .asList();
    }

    public static List<Account> getAccountsWithoutSharing() {
        return AccountSelector.Query
            .systemMode()
            .withoutSharing()
            .asList();
    }
}
```
