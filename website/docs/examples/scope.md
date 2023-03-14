---
sidebar_position: 5
---

# Scope

```java
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

    public static List<Account> getMineAccounts() {
        return (List<Account>) QS_Account.Selector
            .mineScope()
            .asList();
    }

    public static List<Account> getTeamAccounts() {
        return (List<Account>) QS_Account.Selector
            .myTeamScope()
            .asList();
    }
}
```
