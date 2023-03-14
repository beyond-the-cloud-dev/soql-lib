---
sidebar_position: 3
---

# COUNT()

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType);
        }
    }
}

public with sharing class MyController {

    public static Integer getAccountAmount() {
        return QS_Account.Selector.count().asInteger();
    }

    public static Integer getUniqueAccountNameAmount() {
        return QS_Account.Selector.countAs(Account.Name, 'names').asAggregated()[0].names;
    }
}
```
