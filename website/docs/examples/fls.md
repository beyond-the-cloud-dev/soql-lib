---
sidebar_position: 11
---

# Field Level Security

USER_MODE is a default option. You can set SYSTEM_MODE for all queries by adding `systemMode()` to selector class.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                })
                .systemMode(); //default fls mode
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountInSystemMode() {
        return (List<Account>) QS_Account.Selector
            .userMode() //override selector fls mode
            .asList();
    }
}
```
