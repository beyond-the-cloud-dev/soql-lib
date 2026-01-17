---
sidebar_position: 15
---

# Basic Features

## Dynamic SOQL

The `SOQL.cls` class provides methods for building SOQL clauses dynamically.

❌

```apex title="Dynamic Query with String"
String accountName = '';

String query = 'SELECT Id, Name WHERE BillingCity = \'Krakow\'';

if (String.isNotEmpty(accountName)) {
    query += ' AND Name LIKE \'%' + accountName +'\%';
}

query += ' FROM Account';

Database.query(query);
```

✅

```apex title="Dynamic Query with SOQL Lib"
String accountName = '';

SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
        .add(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    )
    .toList();
```

## Automatic Binding

All variables used in the `WHERE` condition are automatically bound.

```apex title="Automatic Variable Binding"
// SELECT Id, Name FROM Account WHERE Name = :v1
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Name).contains('Test'))
    .toList();
```

```apex title="Generated Binding Map"
// Binding Map
{
  "v1" : "%Test%"
}
```


## Minimalistic Selectors

The selector constructor maintains default configurations such as default fields, sharing mode, and field-level security settings. Only essential, reusable methods are maintained in the selector class, with each method returning an instance of the selector to enable method chaining.

Additional fields, complex conditions, ordering, limits, and other SOQL clauses can be built dynamically where they are needed (for example, in controller methods), keeping the selector focused on core functionality.

```apex title="SOQL_Account.cls"
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static final String MOCK_ID = 'SOQL_Account';

    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // Default configuration
        with(Account.Id, Account.Name);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Account byType(String type) {
        whereAre(Filter.with(Account.Type).equal(type));
        return this;
    }

    public SOQL_Account byIndustry(String industry) {
        whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }

    public SOQL_Account byOwnerId(Id ownerId) {
        whereAre(Filter.with(Account.OwnerId).equal(ownerId));
        return this;
    }
}
```


**Usage Example:**

```apex title="Selector Usage Examples"
// Basic usage with default configuration
// SELECT Id, NAME FROM Account WITH SYSTEM_MODE
List<Account> allAccounts = SOQL_Account.query().toList();

// Chain selector methods
/*
    SELECT Id, Name, AnnualRevenue 
    FROM Account
    WHERE Type = 'Partner' AND Industry = 'Technology'
    WITH SYSTEM_MODE
*/
List<Account> techPartners = SOQL_Account.query()
    .byType('Partner')
    .byIndustry('Technology')
    .with(Account.AnnualRevenue) // pull additional fields
    .toList();

// Extend with additional fields and clauses dynamically
/*
    SELECT Id, Name, AnnualRevenue, BillingCity
    FROM Account
    WHERE Industry = 'Technology' AND AnnualRevenue > 1000000
    ORDER BY AnnualRevenue DESC
    WITH SYSTEM_MODE
    LIMIT 10
*/
List<Account> topAccounts = SOQL_Account.query()
    .byIndustry('Technology')
    .whereAre(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
    .with(Account.AnnualRevenue, Account.BillingCity)
    .orderBy(Account.AnnualRevenue).sortDesc()
    .setLimit(10)
    .toList();
```

## Minimal Fields

SOQL Lib selectors are designed to include only a minimal set of default fields in their constructor, typically just essential identifiers and commonly used fields. This approach significantly improves query performance and promotes reusability by avoiding unnecessary data retrieval.

**Design Philosophy:**
The selector constructor defines the minimum viable field set that covers the majority of use cases. Additional fields are added dynamically where they are actually needed, following the principle of <u>**"pull only what you need, when you need it."**</u>

```apex title="SOQL_Contact.cls - Minimal Fields"
public inherited sharing class SOQL_Contact extends SOQL implements SOQL.Selector {
    public static SOQL_Contact query() {
        return new SOQL_Contact();
    }

    private SOQL_Contact() {
        super(Contact.SObjectType);
        // Minimal default fields - only essentials
        with(Contact.Id, Contact.Name, Contact.AccountId)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Contact byAccountId(Id accountId) {
        whereAre(Filter.with(Contact.AccountId).equal(accountId));
        return this;
    }
}
```

**Dynamic Field Addition:**
Additional fields are added at the point of use, keeping the selector lean while providing flexibility for specific business requirements.

```apex title="ExampleController.cls - Dynamic Field Addition"
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Contact> getContactDetails(Id accountId) {
        return SOQL_Contact.query()
            .byAccountId(accountId)
            // Add fields only when needed
            .with(Contact.Email, Contact.Phone, Contact.Department, Contact.Title)
            .with('Account', Account.Name, Account.Industry)
            .orderBy(Contact.LastName)
            .setLimit(100)
            .toList();
    }

    @AuraEnabled
    public static List<Contact> getBasicContacts(Id accountId) {
        // Uses only default fields (Id, Name, AccountId)
        return SOQL_Contact.query()
            .byAccountId(accountId)
            .toList();
    }
}
```

## Field-Level Security Control

[AccessLevel Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_AccessLevel.htm)

Object permissions and field-level security are controlled by SOQL Lib. Developers can change FLS settings to match business requirements.

### User Mode

By default, all queries are executed in `AccessLevel.USER_MODE`.

> The object permissions, field-level security, and sharing rules of the current user are enforced.

### System Mode

Developers can change the mode to `AccessLevel.SYSTEM_MODE` by using the `.systemMode()` method.

> The object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the sharing mode.

```apex title="System Mode Query"
// SELECT Id FROM Account - skip FLS
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .toList();
```

## Sharing Control

[Apex Sharing](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

> Use the with sharing or without sharing keywords on a class to specify whether sharing rules must be enforced. Use the inherited sharing keyword on a class to run the class in the sharing mode of the class that called it.

### With Sharing

By default, all queries are executed `with sharing`, enforced by `AccessLevel.USER_MODE`.

`AccessLevel.USER_MODE` enforces object permissions and field-level security.

Developers can skip FLS by adding `.systemMode()` and `.withSharing()`.

```apex title="With Sharing Example"
// Query executed with sharing (respects sharing rules)
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .withSharing()
    .toList();
```

### Without Sharing

Developers can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharing mode) and `.withoutSharing()`.

```apex title="Without Sharing Example"
// Query executed without sharing (bypasses sharing rules)
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .withoutSharing()
    .toList();
```

### Inherited Sharing

Developers can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharing mode); by default it is `inherited sharing`.

```apex title="Inherited Sharing Example"
// Query executed in inherited sharing
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .toList();
```

## Mocking

Mocking provides a way to substitute database records with prepared test data. Data can be prepared as SObject records and lists in Apex code or as Static Resource `.csv` files.

Mocked queries won't execute any SOQL statements and simply return the data set in the method definition. **Mocks will ignore all filters and relations** - what is returned depends **solely on the data provided to the method**. Mocking works **only during test execution**. 

To mock a SOQL query, use the `.mockId(id)` method to make it identifiable. If you mark more than one query with the same ID, all marked queries will return the same data.

```apex title="ExampleController.cls - With Mocking"
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

```apex title="Mock Test - List of Records"
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

```apex title="Mock Test - Single Record"
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

```apex title="Mock Test - Static Resource"
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

```apex title="Mock Test - Count Result"
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

```apex title="Mock Test - Aggregate Result"
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

## Avoid Query Duplication

Generic SOQL queries can be kept in the selector class to promote reusability and maintainability.

```apex title="SOQL_Account.cls - Reusable Methods"
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

## Default Configuration

The selector class can provide default SOQL configurations including default fields, FLS settings, and sharing rules that will be applied to all queries.

```apex title="SOQL_Account.cls - Default Configuration"
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

## Dynamic Conditions

Build your conditions dynamically based on runtime logic.

**Ignore Condition**

Ignore a condition when a logical expression evaluates to true.

```apex title="Dynamic Conditions - Ignore When"
// SELECT Id FROM Account WHERE BillingCity = 'Krakow'

String accountName = '';

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
        .add(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    ).toList();
```

**Filter Group**

Create [SOQL.FilterGroup](../soql/api/soql-filters-group.md) and assign conditions dynamically based on your specific criteria.

```apex title="Dynamic Conditions - Filter Group"
public List<Account> getAccounts() {
    SOQL.FilterGroup filterGroup;

    if (UserInfo.getUserType() == 'PowerPartner') {
        filterGroup = SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.Name).equal('Test'))
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

## Enhanced Result Methods

SOQL Lib provides enhanced result transformation methods to simplify common data operations.
You can use many predefined methods that reduce code complexity and improve readability.

```apex title="Available Result Methods"
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

```apex title="Traditional Approach - Custom Map"
public static Map<Id, Id> getContactIdByAccontId() {
    Map<Id, Id> contactIdToAccountId = new Map<Id, Id>();

    for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
        contactIdToAccountId.put(contact.Id, contact.AccountId)
    }

    return contactIdToAccountId;
}
```

✅

```apex title="SOQL Lib Approach - Custom Map"
public static Map<String, String> getContactIdByAccontId() {
    return SOQL_Contact.query().toMap(Contact.Id, Contact.AccountId);
}
```

Extract unique values from query:

❌

```apex title="Traditional Approach - Unique Values"
public static Set<String> getAccountNames() {
    Set<String> accountNames = new Set<String>();

    for (Account account : [SELECT Name FROM Account]) {
        accountNames.add(account.Name);
    }

    return accountNames;
}
```

✅

```apex title="SOQL Lib Approach - Unique Values"
public static Set<String> getAccountNames() {
    return SOQL_Account.query().toValuesOf(Account.Name);
}
```

Extract unique IDs from query:

❌

```apex title="Traditional Approach - Unique IDs"
public static Set<Id> getAccountOwnerIds() {
    Set<Id> ownerIds = new Set<Id>();

    for (Account account : [SELECT OwnerId FROM Account]) {
        ownerIds.add(account.OwnerId);
    }

    return ownerIds;
}
```

✅

```apex title="SOQL Lib Approach - Unique IDs"
public static Set<Id> getAccountOwnerIds() {
    return SOQL_Account.query().toIdsOf(Account.OwnerId);
}
```

Extract single ID from query:

❌

```apex title="Traditional Approach - Single ID"
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

```apex title="SOQL Lib Approach - Single ID"
public static Id getSystemAdminProfileId() {
    return SOQL.of(Profile.SObjectType)
        .whereAre(SOQL.Filter.with(Profile.Name).equal('System Administrator'))
        .toId();
}
```

Extract IDs from related fields:

❌

```apex title="Traditional Approach - Related IDs"
public static Set<Id> getParentAccountIds() {
    Set<Id> parentIds = new Set<Id>();

    for (Account account : [SELECT Parent.Id FROM Account WHERE Parent.Id != null]) {
        parentIds.add(account.Parent.Id);
    }

    return parentIds;
}
```

✅

```apex title="SOQL Lib Approach - Related IDs"
public static Set<Id> getParentAccountIds() {
    return SOQL.of(Account.SObjectType)
        .toIdsOf('Parent', Account.Id);
}
```

Extract all record IDs from filtered query:

❌

```apex title="Traditional Approach - Filtered IDs"
public static Set<Id> getTechnologyAccountIds() {
    Set<Id> accountIds = new Set<Id>();

    for (Account account : [SELECT Id FROM Account WHERE Industry = 'Technology']) {
        accountIds.add(account.Id);
    }

    return accountIds;
}
```

✅

```apex title="SOQL Lib Approach - Filtered IDs"
public static Set<Id> getTechnologyAccountIds() {
    return SOQL.of(Account.SObjectType)
        .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
        .toIds();
}
```
