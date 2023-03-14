---
sidebar_position: 8
---

# ORDER BY


```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Lead.sObjectType)
                 .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name,
                    Account.Industry
                });;
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return (List<Account>) QS_Account.Selector
                .orderBy(Account.Industry).sortDesc()
                .orderBy(Account.Id)
                .asList();
    }
}
```
