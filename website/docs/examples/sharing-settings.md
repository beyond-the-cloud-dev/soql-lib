---
sidebar_position: 12
---

# Sharing

`with sharing` is a default option option, because of `USER_MODE`.

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

    public static List<Account> getAccountsWithSharing() {
        return AccountSelector.Query
            .systemMode() // FLS will be not respected
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
