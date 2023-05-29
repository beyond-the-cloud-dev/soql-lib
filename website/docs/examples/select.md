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
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name); //default fields
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return AccountSelector.query()
            .with(
                Account.BillingCity,
                Account.BillingState,
                Account.BillingStreet,
                Account.BillingCountry
            )
            .toList();
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
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType) //default fields
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithCreatedBy() {
        return AccountSelector.query()
            .with('CreatedBy', User.Id, User.Name)
            .toList();
    }
}
```

## Count

```sql
SELECT COUNT() FROM Account

SELECT COUNT(Name) names FROM Account
```
```apex
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType);
    }
}

public with sharing class MyController {

    public static Integer getAccountAmount() {
        return AccountSelector.query().count().toInteger();
    }

    public static Integer getUniqueAccountNameAmount() {
        return AccountSelector.query().count(Account.Name, 'names').toAggregated()[0].names;
    }
}
```
