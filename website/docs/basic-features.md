---
sidebar_position: 3
---

# Basic Features

## Dynamic SOQL

`SOQL.cls` class provides methods for building SOQL clauses dynamically.

```apex
// SELECT Id FROM Account LIMIT 100
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .setLimit(100)
    .toList();
```


## Automatic binding

All variables used in the `WHERE` condition are automatically binded.

```apex
// SELECT Id, Name FROM Account WHERE Name = :v1
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Name).contains('Test'))
    .toList();
```

```apex
// Binding Map
{
  "v1" : "%Test%"
}
```

## Control FLS

[AccessLevel Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_AccessLevel.htm)

Object permissions and field-level security are controlled by the lib. Developers can change FLS settings to match business requirements.

### User mode

By default, all queries are executed in `AccessLevel.USER_MODE`.

> The object permissions, field-level security, and sharing rules of the current user are enforced.

### System mode

Developers can change the mode to `AccessLevel.SYSTEM_MODE` by using the `.systemMode()` method.

> The object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the sharingMode.

```apex
// SELECT Id FROM Account - skip FLS
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .toList();
```

## Control Sharings

[Apex Sharing](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

> Use the with sharing or without sharing keywords on a class to specify whether sharing rules must be enforced. Use the inherited sharing keyword on a class to run the class in the sharing mode of the class that called it.

### with sharing

By default, all queries are executed `with sharing`, enforced by `AccessLevel.USER_MODE`.

`AccessLevel.USER_MODE` enforces object permissions and field-level security.

Developer can skip FLS by adding `.systemMode()` and `.withSharing()`.

```apex
// Query executed in without sharing
SOQL.of(Account.SObjectType).with(Account.Id, Account.Name)
    .systemMode()
    .withSharing()
    .toList();
```

### without sharing

Developer can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode) and `.withoutSharing()`.

```apex
// Query executed in with sharing
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .withoutSharing()
    .toList();
```

### inherited sharing

Developer can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode) by default it is `inherited sharing`.

```apex
// Query executed in inherited sharing
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .toList();
```

## Mocking

Mocking provides a way to substitute records from a Database with some prepared data. Data can be prepared in form of SObject records and lists in Apex code or Static Resource `.csv` file.
Mocked queries won't make any SOQL's and simply return data set in method definition, mock __will ignore all filters and relations__, what is returned depends __solely on data provided to the method__. Mocking is working __only during test execution__. To mock SOQL query, use `.mockId(id)` method to make it identifiable. If you mark more than one query with the same ID, all marked queries will return the same data.

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .toList();
    }
}
```

Then in test simply pass data you want to get from Selector to `SOQL.setMock(id, data)` method. Acceptable formats are: `List<SObject>`, `SObject`, or `String` with name of static resource. Then during execution Selector will return desired data.

### List of records

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.setMock('ExampleController.getPartnerAccounts', accounts);

        // Test
        List<Account> result = ExampleController.getAccounts('MyAccount');

        Assert.areEqual(accounts, result);
    }
}
```

### Single record

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccount() {
        SOQL.setMock('ExampleController.getPartnerAccount', new Account(Name = 'MyAccount 1'));

        // Test
        Account result = (Account) ExampleController.getAccounts('MyAccount');

        Assert.areEqual('MyAccount 1', result.Name);
    }
}
```

### Static resource
```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.setMock('ExampleController.getPartnerAccounts', 'ProjectAccounts');

        // Test
        List<Account> result = ExampleController.getAccounts('MyAccount');

        Assert.areEqual(5, result.size());
    }
}
```

### Count Result

```
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.setCountMock('mockingQuery', 2);

        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').toInteger();

        Assert.areEqual(2, result);
    }
}
```

## Avoid duplicates

Generic SOQLs can be keep in selector class.

```apex
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byRecordType(String rtDevName) {
        return query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.recordType().equal(rtDevName));
    }
}
```

## Default configuration

The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.

```apex
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name) // default fields
            .systemMode(); // default FLS mode
    }
}
```
