---
sidebar_position: 1
---

# SELECT

## Fields

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

## Parent Fields

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

## Count

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
