---
sidebar_position: 8
---

# ORDER BY


```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Lead.sObjectType)
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
        return (List<Account>) AccountSelector.Query
                .orderBy(Account.Industry).sortDesc()
                .orderBy(Account.Id)
                .asList();
    }
}
```
