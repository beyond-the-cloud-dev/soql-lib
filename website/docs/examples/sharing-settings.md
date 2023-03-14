---
sidebar_position: 12
---

# SHARING

INHERITED SHARING is a default option.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(QS_Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithSharing() {
        return (List<Account>) QS_Account.Selector
            .withSharing()
            .asList();
    }

    public static List<Account> getAccountsWithoutSharing() {
        return (List<Account>) QS_Account.Selector
            .withoutSharing()
            .asList();
    }
}
```
