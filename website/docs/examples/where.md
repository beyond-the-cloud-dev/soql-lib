---
sidebar_position: 6
---

# WHERE

```apex
public inherited sharing class QS_YourObject {

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

    public static List<Account> getByIdOrName(Id accountId, String accountName) {
        return (List<Account>) QS_Account.Selector
                .whereAre(QS.ConditionsGroup
                    .add(QS.Condition.field(Account.Id).equal(accountId))
                    .add(QS.Condition.field(Account.Name).likeAnyBoth(accountName))
                    .order('1 OR 2')
                )
                .asList();
    }
}
```
