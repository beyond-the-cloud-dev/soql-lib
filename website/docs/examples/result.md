---
sidebar_position: 15
---

# Result

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

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return (List<Account>) QS_Account.Selector
            .whereAre(QS.Condition.id().isIn(accountIds))
            .asList();
    }

    public static Account getAccountById(Id accountId) {
        return (Account) QS_Account.Selector
            .whereAre(QS.Condition.id().equal(accountId))
            .asObject();
    }
}
```
