---
sidebar_position: 1
---

# SELECT

## Fields

You are able to add a default fields to selector class. More fields can be added in a place of usage.

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            // default fields
            return SOQL.of(Account.sObjectType)
                .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        //SELECT Id, Name, BillingCity, BillingState, BillingStreet, BillingCountry FROM Account
        return AccountSelector.Query
            .with(new List<sObjectField>{
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
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            // default fields
            return SOQL.of(Account.sObjectType)
                .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithCreatedBy() {
        //SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM Account
        return AccountSelector.Query
            .with('CreatedBy', new List<sObjectField>{
                User.Id,
                User.Name
            }).asList();
    }
}
```

## Count

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType);
        }
    }
}

public with sharing class MyController {

    public static Integer getAccountAmount() {
        //SELECT COUNT() FROM Account
        return AccountSelector.Query.count().asInteger();
    }

    public static Integer getUniqueAccountNameAmount() {
        //SELECT COUNT(Name) names FROM Account
        return AccountSelector.Query.countAs(Account.Name, 'names').asAggregated()[0].names;
    }
}
```
