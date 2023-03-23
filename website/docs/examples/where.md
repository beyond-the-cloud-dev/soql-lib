---
sidebar_position: 6
---

# WHERE

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getByIdOrName(Id accountId, String accountName) {
        return (List<Account>) AccountSelector.Query
                .whereAre(SOQL.ConditionsGroup
                    .add(SOQL.Condition.field(Account.Id).equal(accountId))
                    .add(SOQL.Condition.field(Account.Name).likeAnyBoth(accountName))
                    .order('1 OR 2')
                )
                .asList();
    }
}
```
