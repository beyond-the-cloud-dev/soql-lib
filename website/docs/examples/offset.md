---
sidebar_position: 10
---

# OFFSET

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

    public static List<Account> getAccountsWithContacts() {
        return (List<Account>) QS_Account.Selector
            .setOffset(2000)
            .asList();
    }
}
```
