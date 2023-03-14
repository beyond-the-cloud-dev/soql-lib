---
sidebar_position: 1
---

# SELECT Fields

You are able to add a default fields to selector class. More fields can be added in a place of usage.

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

    public static List<Account> getAccounts() {
        return (List<Account>) QS_Account.Selector
            .fields(new List<sObjectField>{
                Account.BillingCity,
                Account.BillingState,
                Account.BillingStreet,
                Account.BillingCountry
            }).asList();
    }
}
```
