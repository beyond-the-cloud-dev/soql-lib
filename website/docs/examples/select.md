---
sidebar_position: 1
---

# SELECT

Specify fields that will be retrieved via query.

## Fields

You are able to add a default fields to selector class. More fields can be added in a place of usage.

```sql
SELECT Id, Name, BillingCity, BillingState, BillingStreet, BillingCountry
FROM Account
```
```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.SObjectType)
                .with(new List<SObjectField>{ //default fields
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return AccountSelector.Query
            .with(new List<SObjectField>{
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

```sql
SELECT Id, Name, CreatedBy.Id, CreatedBy.Name
FROM Account
```
```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.SObjectType) //default fields
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithCreatedBy() {
        return AccountSelector.Query
            .with('CreatedBy', new List<SObjectField>{
                User.Id,
                User.Name
            }).asList();
    }
}
```

## Count

```sql
SELECT COUNT() FROM Account

SELECT COUNT(Name) names FROM Account
```
```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.SObjectType);
        }
    }
}

public with sharing class MyController {

    public static Integer getAccountAmount() {
        return AccountSelector.Query.count().asInteger();
    }

    public static Integer getUniqueAccountNameAmount() {
        return AccountSelector.Query.countAs(Account.Name, 'names').asAggregated()[0].names;
    }
}
```
