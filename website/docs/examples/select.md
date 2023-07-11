---
sidebar_position: 1
---

# SELECT

Specify fields that will be retrieved via query. Check [SOQL API - SELECT](../api/soql.md#select).

## Fields

You are able to add a default fields to selector class. More fields can be added in a place of usage.

```sql
SELECT Id, Name, BillingCity, BillingState, BillingStreet
FROM Account
```
```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name); //default fields
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingState, Account.BillingStreet)
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
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType) //default fields
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithCreatedBy() {
        return SOQL_Account.query()
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
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType);
    }
}

public with sharing class MyController {

    public static Integer getAccountAmount() {
        return SOQL_Account.query().count().toInteger();
    }

    public static Integer getUniqueAccountNameAmount() {
        return SOQL_Account.query().count(Account.Name, 'names').toAggregated()[0].names;
    }
}
```
