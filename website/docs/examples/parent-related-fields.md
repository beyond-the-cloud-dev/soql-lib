---
sidebar_position: 2
---

# SELECT Parent.Field

Specify relationship name and pass parent object fields.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            // default fields
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithCreatedBy() {
        return (List<Account>) QS_Account.Selector
            .relatedFields('CreatedBy', new List<sObjectField>{
                User.Id,
                User.Name
            }).asList();
    }
}
```
