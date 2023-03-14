---
sidebar_position: 10
---

# OFFSET

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithOffset(Integer startingRow) {
        return (List<Account>) QS_Account.Selector
            .setOffset(startingRow)
            .asList();
    }
}
```
