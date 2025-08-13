---
sidebar_position: 30
---

# Basic Features

## Dynamic SOQL

The `SOQL.cls` class provides methods for building SOQL clauses dynamically.

```apex
// SELECT Id FROM Account LIMIT 100
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .setLimit(100)
    .toList();
```

```apex
String accountName = '';

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
        .add(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    )
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

Developers can skip FLS by adding `.systemMode()` and `.withSharing()`.

```apex
// Query executed in without sharing
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .withSharing()
    .toList();
```

### without sharing

Developers can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode) and `.withoutSharing()`.

```apex
// Query executed in with sharing
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .withoutSharing()
    .toList();
```

### inherited sharing

Developers can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode); by default it is `inherited sharing`.

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
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .toList();
    }
}
```

Then in test simply pass data you want to get from Selector to `SOQL.mock(id).thenReturn(data)` method. Acceptable formats are: `List<SObject>` or `SObject`. Then during execution Selector will return desired data.

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

        SOQL.mock('ExampleController.getPartnerAccounts').thenReturn(accounts);

        // Test
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');

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
        SOQL.mock('ExampleController.getPartnerAccount').thenReturn(new Account(Name = 'MyAccount 1'));

        // Test
        Account result = (Account) ExampleController.getPartnerAccounts('MyAccount');

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
        SOQL.mock('ExampleController.getPartnerAccounts').thenReturn(Test.loadData(Account.SObjectType, 'ProjectAccounts'));

        // Test
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual(5, result.size());
    }
}
```

### Count Result

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.mock('mockingQuery').thenReturn(2);

        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').toInteger();

        Assert.areEqual(2, result);
    }
}
```

### Aggregate Result

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getLeadSourceCounts() {
        List<Map<String, Object>> aggregateResults = new List<Map<String, Object>>{
            new Map<String, Object>{ 'LeadSource' => 'Web',  'total' => 10},
            new Map<String, Object>{ 'LeadSource' => 'Phone', 'total' => 5},
            new Map<String, Object>{ 'LeadSource' => 'Email', 'total' => 3}
        };

        SOQL.mock('mockingQuery').thenReturn(aggregateResults);

        List<SOQL.AggregateResultProxy> result = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource)
            .count(Lead.Id, 'total')
            .groupBy(Lead.LeadSource)
            .mockId('mockingQuery')
            .toAggregatedProxy();

        Assert.areEqual(3, result.size());
        Assert.areEqual(10, result[0].get('total'));
        Assert.areEqual('Web', result[0].get('LeadSource'));
    }
}
```

## Avoid duplicates

Generic SOQLs can be kept in the selector class.

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Account byIndustry(String industry) {
        with(Account.Industry)
            .whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        with(Account.ParentId)
            .whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }

    public String toIndustry(Id accountId) {
        return (String) byId(accountId).toValueOf(Account.Industry);
    }
}
```

## Default configuration

The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules that will be applied to all queries.

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // default configuration
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }
}
```

## Dynamic conditions

Build your conditions in a dynamic way.

**Ignore condition**

Ignore condition when logic expression evaluate to true.

```apex
// SELECT Id FROM Account WHERE BillingCity = 'Krakow'

String accountName = '';

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
        .add(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    ).toList();
```

**Filter Group**

Create [SOQL.FilterGroup](../api/standard-soql/soql-filters-group.md) and assign conditions dynamically based on your own criteria.

```apex
public List<Account> getAccounts() {
    SOQL.FilterGroup filterGroup;

    if (UserInfo.getUserType() == 'PowerPartner')
        filterGroup = SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.Name).equal('Test'));
            .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'));
    } else {
        filterGroup = SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.Name).equal('Other Test'));
    }

    return SOQL.of(Account.SObjectType)
        .whereAre(filterGroup)
        .toList();
}
```

## Cache records

Did you know that?

- Retrieving data from the cache takes less than 10ms.
- Read operations (SOQL) account for approximately 70% of an org’s activity.

Cache can significantly boost your org's performance. You can use it for objects like:

- `Profile`
- `BusinessHours`
- `OrgWideEmailAddress`
- `User`

To use cached records you can use Cached Selectors.

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        with(Profile.Id, Profile.Name, Profile.UserType);
        maxHoursWithoutRefresh(24);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType);
    }

    public SOQL_ProfileCache byName(String name) {
        whereEqual(Profile.Name, name);
        return this;
    }
}
```

## Enhanced SOQL

Developers perform different SOQL result transformations.
You can use many predefined methods that will reduce your code complexity.

```apex
Id toId();
Set<Id> toIds();
Set<Id> toIdsOf(SObjectField field);
Set<Id> toIdsOf(String relationshipName, SObjectField field);
Boolean doExist();
String toString();
Object toValueOf(SObjectField fieldToExtract);
Set<String> toValuesOf(SObjectField fieldToExtract);
Set<String> toValuesOf(String relationshipName, SObjectField targetKeyField);
Integer toInteger();
SObject toObject();
List<SObject> toList();
List<AggregateResult> toAggregated();
List<AggregateResultProxy> toAggregatedProxy();
Map<Id, SObject> toMap();
Map<String, SObject> toMap(SObjectField keyField);
Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField);
Map<String, String> toMap(SObjectField keyField, SObjectField valueField);
Map<String, List<SObject>> toAggregatedMap(SObjectField keyField);
Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField);
Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField);
Database.QueryLocator toQueryLocator();
```

Build map with custom key:

❌

```apex
public static Map<Id, Id> getContactIdByAccontId() {
    Map<Id, Id> contactIdToAccountId = new Map<Id, Id>();

    for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
        contactIdToAccountId.put(contact.Id, contact.AccountId)
    }

    return contactIdToAccountId;
}
```

✅

```apex
public static Map<String, String> getContactIdByAccontId() {
    return SOQL_Contact.query().toMap(Contact.Id, Contact.AccountId);
}
```

Extract unique values from query:

❌

```apex
public static Set<String> getAccountNames() {
    Set<String> accountNames = new Set<String>();

    for (Account account : [SELECT Name FROM Account]) {
        accountNames.add(account.Name);
    }

    return accountNames;
}
```

✅

```apex
public static Set<String> getAccountNames() {
    return SOQL_Account.query().toValuesOf(Account.Name);
}
```

Extract unique IDs from query:

❌

```apex
public static Set<Id> getAccountOwnerIds() {
    Set<Id> ownerIds = new Set<Id>();

    for (Account account : [SELECT OwnerId FROM Account]) {
        ownerIds.add(account.OwnerId);
    }

    return ownerIds;
}
```

✅

```apex
public static Set<Id> getAccountOwnerIds() {
    return SOQL_Account.query().toIdsOf(Account.OwnerId);
}
```

Extract single ID from query:

❌

```apex
public static Id getSystemAdminProfileId() {
    Profile profile = [
        SELECT Id 
        FROM Profile 
        WHERE Name = 'System Administrator' 
        LIMIT 1
    ];
    return profile.Id;
}
```

✅

```apex
public static Id getSystemAdminProfileId() {
    return SOQL.of(Profile.SObjectType)
        .whereAre(SOQL.Filter.with(Profile.Name).equal('System Administrator'))
        .toId();
}
```

Extract IDs from related fields:

❌

```apex
public static Set<Id> getParentAccountIds() {
    Set<Id> parentIds = new Set<Id>();

    for (Account account : [SELECT Parent.Id FROM Account WHERE Parent.Id != null]) {
        if (account.Parent != null) {
            parentIds.add(account.Parent.Id);
        }
    }

    return parentIds;
}
```

✅

```apex
public static Set<Id> getParentAccountIds() {
    return SOQL.of(Account.SObjectType)
        .toIdsOf('Parent', Account.Id);
}
```

Extract all record IDs from filtered query:

❌

```apex
public static Set<Id> getTechnologyAccountIds() {
    Set<Id> accountIds = new Set<Id>();

    for (Account account : [SELECT Id FROM Account WHERE Industry = 'Technology']) {
        accountIds.add(account.Id);
    }

    return accountIds;
}
```

✅

```apex
public static Set<Id> getTechnologyAccountIds() {
    return SOQL.of(Account.SObjectType)
        .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
        .toIds();
}
```
