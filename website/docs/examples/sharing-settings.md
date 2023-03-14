---
sidebar_position: 12
---

# SHARING

`with inherited sharing` is a default option.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                })
                .withSharing(); //default sharing settings
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithSharing() {
        return (List<Account>) QS_Account.Selector
            .asList();
    }

    public static List<Account> getAccountsWithoutSharing() {
        return (List<Account>) QS_Account.Selector
            .withoutSharing() //override sharing settings
            .asList();
    }
}
```
