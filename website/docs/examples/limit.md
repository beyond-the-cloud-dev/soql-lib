---
sidebar_position: 9
---

# LIMIT

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

    public static List<Account> getAccountsWithLimit(Integer amount) {
        return (List<Account>) QS_Account.Selector
            .setLimit(amount)
            .asList();
    }
}
```
