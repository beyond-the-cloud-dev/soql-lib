---
sidebar_position: 10
---

# SOQL Evaluator

Apex Classes: `SOQLEvaluator.cls` and `SOQLEvaluator_Test.cls`.

The lib evaluator class for processing of queried records.

```apex
List<Account> accounts = SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toList();
```

## Methods

The following are methods for using `SOQLEvaluator`:

[**INIT**](#init)

- [`of(List<SObject> staticQueryRecords)`](#of)

[**FIELD-LEVEL SECURITY**](#field-level-security)

- [`stripInaccessible()`](#stripinaccessible)
- [`stripInaccessible(AccessType accessType)`](#stripinaccessible)

[**MOCKING**](#mocking)

- [`mockId(String mockId)`](#mockid)
- [`SOQLEvaluator.mock(String mockId).thenReturn(SObject record)`](#record-mock)
- [`SOQLEvaluator.mock(String mockId).thenReturn(List<SObject> records)`](#records-mock)

[**RESULT**](#result)

- [`toId()`](#toid)
- [`toIds()`](#toids)
- [`toIdsOf(SObjectField field)`](#toidsof)
- [`toIdsOf(String relationshipName, SObjectField field)`](#toidsof-related-field)
- [`doExist()`](#doexist)
- [`toValueOf(SObjectField fieldToExtract)`](#tovalueof)
- [`toValuesOf(SObjectField fieldToExtract)`](#tovaluesof)
- [`toObject()`](#toobject)
- [`toList()`](#tolist)
- [`toMap()`](#tomap)
- [`toMap(SObjectField keyField)`](#tomap-with-custom-key)
- [`toMap(String relationshipName, SObjectField targetKeyField)`](#tomap-with-custom-relationship-key)
- [`toMap(SObjectField keyField, SObjectField valueField)`](#tomap-with-custom-key-and-value)
- [`toAggregatedMap(SObjectField keyField)`](#toaggregatedmap)
- [`toAggregatedMap(String relationshipName, SObjectField targetKeyField)`](#toaggregatedmap-with-custom-relationship-key)
- [`toAggregatedMap(SObjectField keyField, SObjectField valueField)`](#toaggregatedmap-with-custom-value)

## INIT
### of

Constructs a `SOQLEvaluator` from existing SObject records.

**Signature**

```apex
SObjectEvaluable of(List<SObject> staticQueryRecords)
```

**Example**

```apex
SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toList();
```

## FIELD-LEVEL SECURITY

### stripInaccessible

The `Security.stripInaccessible` method removes inaccessible fields from the existing records based on the current user's permissions.

**Signature**

```apex
SObjectEvaluable stripInaccessible()
SObjectEvaluable stripInaccessible(AccessType accessType)
```

**Example**

```apex
List<Account> accessibleAccounts = SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).stripInaccessible().toList();

// or with specific access type
List<Account> readableAccounts = SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).stripInaccessible(AccessType.READABLE).toList();
```

## MOCKING

### mockId

Evaluator needs unique id that allows for mocking.

**Signature**

```apex
SObjectEvaluable mockId(String mockId)
```

**Example**

```apex
SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).mockId('MyEvaluator').toList();

// In Unit Test
SOQLEvaluator.mock('MyEvaluator').thenReturn(new List<Account>{
    new Account(Name = 'Mocked Account 1'),
    new Account(Name = 'Mocked Account 2')
});
```

### record mock

**Signature**

```apex
SOQLEvaluator.Mockable mock(String mockId).thenReturn(SObject record)
```

**Example**

```apex
SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).mockId('MyEvaluator').toObject();

// In Unit Test
SOQLEvaluator.mock('MyEvaluator').thenReturn(new Account(Name = 'Mocked Account'));
```

### records mock

**Signature**

```apex
SOQLEvaluator.Mockable mock(String mockId).thenReturn(List<SObject> records)
```

**Example**

```apex
SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).mockId('MyEvaluator').toList();

// In Unit Test
SOQLEvaluator.mock('MyEvaluator').thenReturn(new List<Account>{
    new Account(Name = 'Mocked Account 1'),
    new Account(Name = 'Mocked Account 2')
});
```

## RESULT

### toId

**Signature**

```apex
Id toId()
```

**Example**

```apex
Id accountId = SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
    LIMIT 1
]).toId();
```

### toIds

Extract all record IDs from the collection.

**Signature**

```apex
Set<Id> toIds()
```

**Example**

```apex
Set<Id> accountIds = SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toIds();
```

### toIdsOf

Extract field values as Set of IDs from the collection.

**Signature**

```apex
Set<Id> toIdsOf(SObjectField field)
```

**Example**

```apex
Set<Id> ownerIds = SOQLEvaluator.of([
    SELECT Id, Name, OwnerId 
    FROM Account
    WITH USER_MODE
]).toIdsOf(Account.OwnerId);
```

### toIdsOf Related Field

**Signature**

```apex
Set<Id> toIdsOf(String relationshipName, SObjectField field)
```

**Example**

```apex
Set<Id> parentAccountIds = SOQLEvaluator.of([
    SELECT Id, Name, Parent.Id 
    FROM Account
    WITH USER_MODE
]).toIdsOf('Parent', Account.Id);
```

### doExist

**Signature**

```apex
Boolean doExist()
```

**Example**

```apex
Boolean recordsExist = SOQLEvaluator.of([
    SELECT Id 
    FROM Account 
    WHERE Name = 'Test'
    WITH USER_MODE
]).doExist();
```

### toValueOf

Extract field value from the first record in the collection.

**Signature**

```apex
Object toValueOf(SObjectField fieldToExtract)
```

**Example**

```apex
String accountName = (String) SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account 
    WITH USER_MODE
    LIMIT 1
]).toValueOf(Account.Name);
```

### toValuesOf

Extract field values from all records in the collection.

**Signature**

```apex
Set<String> toValuesOf(SObjectField fieldToExtract)
```

**Example**

```apex
Set<String> accountNames = SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toValuesOf(Account.Name);
```

### toObject

When the collection contains more than one record, the error `List has more than 1 row for assignment to SObject` will occur.

When there are no records to assign, the error `List has no rows for assignment to SObject` will **NOT** occur. This is automatically handled by the framework, and a `null` value will be returned instead.

**Signature**

```apex
SObject toObject()
```

**Example**

```apex
Account account = (Account) SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
    LIMIT 1
]).toObject();
```

### toList

**Signature**

```apex
List<SObject> toList()
```

**Example**

```apex
List<Account> processedAccounts = SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toList();
```

### toMap

**Signature**

```apex
Map<Id, SObject> toMap()
```

**Example**

```apex
Map<Id, Account> idToAccount = (Map<Id, Account>) SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toMap();
```

### toMap with custom key

**Signature**

```apex
Map<String, SObject> toMap(SObjectField keyField)
```

**Example**

```apex
Map<String, Account> nameToAccount = (Map<String, Account>) SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toMap(Account.Name);
```

### toMap with custom relationship key

**Signature**

```apex
Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField)
```

**Example**

```apex
Map<String, Account> createdByEmailToAccount = (Map<String, Account>) SOQLEvaluator.of([
    SELECT Id, Name, CreatedBy.Email 
    FROM Account
    WITH USER_MODE
]).toMap('CreatedBy', User.Email);
```

### toMap with custom key and value

**Signature**

```apex
Map<String, String> toMap(SObjectField keyField, SObjectField valueField)
```

**Example**

```apex
Map<String, String> nameToIndustry = SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toMap(Account.Name, Account.Industry);
```

### toAggregatedMap

**Signature**

```apex
Map<String, List<SObject>> toAggregatedMap(SObjectField keyField)
```

**Example**

```apex
Map<String, List<Account>> industryToAccounts = (Map<String, List<Account>>) SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toAggregatedMap(Account.Industry);
```

### toAggregatedMap with custom relationship key

**Signature**

```apex
Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField)
```

**Example**

```apex
Map<String, List<Account>> createdByEmailToAccounts = (Map<String, List<Account>>) SOQLEvaluator.of([
    SELECT Id, Name, CreatedBy.Email 
    FROM Account
    WITH USER_MODE
]).toAggregatedMap('CreatedBy', User.Email);
```

### toAggregatedMap with custom value

**Signature**

```apex
Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField)
```

**Example**

```apex
Map<String, List<String>> industryToAccountNames = SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toAggregatedMap(Account.Industry, Account.Name);
```