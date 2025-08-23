---
sidebar_position: 15
---

# SOQL Cache

Apex Classes: `SOQLCache.cls` and `SOQLCache_Test.cls`.

The lib cache main class necessary to create cached selectors.

```apex title="Basic Usage Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

## Methods

The following are methods for using `SOQLCache`:


[**CACHE STORAGE**](#cache-storage)

- [`cacheInApexTransaction()`](#cacheinapextransaction)
- [`cacheInOrgCache()`](#cacheinorgcache)
- [`cacheInSessionCache()`](#cacheinsessioncache)

[**CACHE EXPIRATION**](#cache-expiration)

- [`maxHoursWithoutRefresh()`](#maxhourswithoutrefresh)
- [`removeFromCache(List<SObject> records)`](#removefromcache)

[**CACHE OPTIONS**](#cache-options)

- [`allowFilteringByNonUniqueFields()`](#allowfilteringbynonuniquefields)
- [`allowQueryWithoutConditions()`](#allowquerywithoutconditions)

[**INITIAL QUERY**](#initial-query)

- [`initialQuery()`](#initialquery)

[**SELECT**](#select)

- [`with(SObjectField field)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#with-field1---field5)
- [`with(List<SObjectField> fields)`](#with-fields)
- [`with(String fields)`](#with-string-fields)
- [`with(String relationshipName, SObjectField field)`](#with-relationship-field)
- [`with(String relationshipName, SObjectField field1, SObjectField field2)`](#with-relationship-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3)`](#with-relationship-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#with-relationship-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#with-relationship-field1---field5)
- [`with(String relationshipName, Iterable<SObjectField> fields)`](#with-relationship-fields)

[**WHERE**](#where)

- [`whereEqual(SObjectField field, Object value)`](#whereequal)
- [`whereEqual(String field, Object value)`](#whereequal)

[**FIELD-LEVEL SECURITY**](#field-level-security)

- [`stripInaccessible()`](#stripinaccessible)
- [`stripInaccessible(AccessType accessType)`](#stripinaccessible)

[**MOCKING**](#mocking)

- [`mockId(String id)`](#mockid)
- [`SOQLCache.mock(String mockId).thenReturn(SObject record)`](#record-mock)

[**DEBUGGING**](#debugging)

- [`preview()`](#preview)

[**PREDEFINIED**](#predefinied)

- [`byId(SObject record)`](#byid)
- [`byId(Id recordId)`](#byid)

[**RESULT**](#result)

- [`toId()`](#toid)
- [`toIdOf(SObjectField field)`](#toidof)
- [`doExist()`](#doexist)
- [`toValueOf(SObjectField fieldToExtract)`](#tovalueof)
- [`toObject()`](#toobject)

## CACHE STORAGE

### cacheInApexTransaction

**Signature**

```apex title="Method Signature"
Cacheable cacheInApexTransaction();
```

**Example**

```apex title="Apex Transaction Cache Implementation"
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInApexTransaction(); // <=== Cache in Apex Transaction
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
}
```

### cacheInOrgCache

**Signature**

```apex title="Method Signature"
Cacheable cacheInOrgCache();
```

**Example**

```apex title="Org Cache Implementation"
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache(); // <=== Cache in Org Cache
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
}
```

### cacheInSessionCache

**Signature**

```apex title="Method Signature"
Cacheable cacheInSessionCache();
```

**Example**

```apex title="Session Cache Implementation"
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInSessionCache(); // <=== Cache in Session Cache
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
}
```

## CACHE EXPIRATION

### maxHoursWithoutRefresh

**Default: 48 hours**

All cached records have an additional field called `cachedDate`. To avoid using outdated records, you can add `maxHoursWithoutRefresh` to your query. This will check how old the cached record is and, if it’s too old, execute a query to update the record in the cache.

**Signature**

```apex title="Method Signature"
Cacheable maxHoursWithoutRefresh(Integer hours)
```

**Example**

```apex title="Cache Auto-Refresh Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .maxHoursWithoutRefresh(12)
    .toObject();
```

### removeFromCache

The `removeFromCache` method allows clearing records from the cache, triggering an automatic refresh the next time the query is executed.

**Signature**

```apex title="Method Signature"
Cacheable removeFromCache(List<SObject> records)
```

**Example**

```apex title="Cache Removal in Trigger"
trigger SomeObjectTrigger on SomeObject (after update, after delete) {
    SOQLCache.removeFromCache(Trigger.new);
}
```

## CACHE OPTIONS

### allowFilteringByNonUniqueFields

By default, cached queries can only filter by unique fields (Id, Name, DeveloperName, or fields marked as unique in the schema). This method allows filtering by non-unique fields.

**Signature**

```apex title="Method Signature"
Cacheable allowFilteringByNonUniqueFields()
```

**Example**

```apex title="Non-Unique Field Filtering"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .allowFilteringByNonUniqueFields()
    .whereEqual(Profile.UserType, 'Standard')
    .toObject();
```

### allowQueryWithoutConditions

By default, cached queries require at least one condition. This method allows queries without any WHERE conditions.

**Signature**

```apex title="Method Signature"
Cacheable allowQueryWithoutConditions()
```

**Example**

```apex title="Query Without Conditions Implementation"
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        allowQueryWithoutConditions();
        with(Profile.Id, Profile.Name, Profile.UserType)
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
    
    public List<Profile> getAllProfiles() {
        // This would require implementing toList() method in SOQLCache
        // For now, this demonstrates the concept of allowing queries without conditions
        return new List<Profile>();
    }
}
```

## INITIAL QUERY

The initial query allows for the bulk population of records in the cache (if it is empty), ensuring that every subsequent query in the cached selector will use the cached records.

For instance:

```apex title="Initial Query Bulk Population"
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        with(Profile.Id, Profile.Name, Profile.UserType)
    }

    public override SOQL.Queryable initialQuery() { // <=== Initial query
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }

    public SOQL_ProfileCache byName(String name) {
        whereEqual(Profile.Name, name);
        return this;
    }
}
```

When the cache is empty, the `initialQuery` will be executed to populate the data in the cache. This allows `SOQL_ProfileCache.query().byName('System Administrator').toObject();` to retrieve the profile from the already cached records, instead of fetching records individually.

### initialQuery

**Signature**

```apex title="Method Signature"
SOQL.Queryable initialQuery()
```

**Example**

```apex title="Initial Query Implementation"
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        with(Profile.Id, Profile.Name, Profile.UserType)
    }

    public override SOQL.Queryable initialQuery() { // <=== Initial query
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
}
```

## SELECT

All selected fields are going to be cached.

### with field1 - field5

**Signature**

```apex title="Method Signatures"
Cacheable with(SObjectField field)
Cacheable with(SObjectField field1, SObjectField field2);
Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3);
Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
```

**Example**

```apex title="Field Selection Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();

SOQL.of(Profile.SObjectType)
    .with(Profile.Id)
    .with(Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

### with fields

Use for more than 5 fields.

**Signature**

```apex title="Method Signature"
Cacheable with(List<SObjectField> fields)
```

**Example**

```apex title="List of Fields Example"
SOQLCache.of(Profile.SObjectType)
    .with(new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType })
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

### with string fields

**NOTE!** With String Apex does not create reference to field. Use `SObjectField` whenever it possible. Method below should be only use for dynamic queries.

**Signature**

```apex title="Method Signature"
Cacheable with(String fields)
```

**Example**

```apex title="String Fields Example"
SOQLCache.of(Profile.SObjectType)
    .with('Id, Name, UserType')
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

### with relationship field

**Signature**

```apex title="Method Signature"
Cacheable with(String relationshipName, SObjectField field)
```

**Example**

```apex title="Relationship Field Example"
SOQLCache.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with('Owner', User.Name)
    .whereEqual(Account.Id, '001000000000000AAA')
    .toObject();
```

### with relationship field1 - field5

**Signature**

```apex title="Method Signatures"
Cacheable with(String relationshipName, SObjectField field1, SObjectField field2)
Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3)
Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)
Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)
```

**Example**

```apex title="Multiple Relationship Fields Example"
SOQLCache.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with('Owner', User.Name, User.Email)
    .whereEqual(Account.Id, '001000000000000AAA')
    .toObject();

SOQLCache.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with('CreatedBy', User.Id, User.Name, User.Email)
    .whereEqual(Account.Id, '001000000000000AAA')
    .toObject();
```

### with relationship fields

Use for more than 5 relationship fields.

**Signature**

```apex title="Method Signature"
Cacheable with(String relationshipName, Iterable<SObjectField> fields)
```

**Example**

```apex title="Relationship Fields List Example"
SOQLCache.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with('Owner', new List<SObjectField>{ User.Id, User.Name, User.Email, User.Title })
    .whereEqual(Account.Id, '001000000000000AAA')
    .toObject();
```

## WHERE

A cached query must include one condition. The filter must use a cached field (defined in `cachedFields()`) and should be based on `Id`, `Name`, `DeveloperName`, or another unique field.

A query requires a single condition, and that condition must filter by a unique field.

To ensure that cached records are aligned with the database, a single condition is required.
A query without a condition cannot guarantee that the number of records in the cache matches the database.

For example, let’s assume a developer makes the query: `SELECT Id, Name FROM Profile`. Cached records will be returned, but they may differ from the records in the database.

The filter field should be unique. Consistency issues can arise when the field is not unique. For instance, the query:
`SELECT Id, Name FROM Profile WHERE UserType = 'Standard'`
may return some records, but the number of records in the cache may differ from those in the database.

Using a unique field ensures that if a record is not found in the cache, the SOQL library can look it up in the database.

**Example**

**Cached Records:**

| Id               | Name                          | UserType               |
|-------------------|-------------------------------|------------------------|
| 00e3V000000Nme3QAC | System Administrator          | Standard               |
| 00e3V000000NmeAQAS | Standard Platform User        | Standard               |
| 00e3V000000NmeHQAS | Customer Community Plus User | PowerCustomerSuccess   |

**Database Records:**

| Id               | Name                          | UserType               |
|-------------------|-------------------------------|------------------------|
| 00e3V000000Nme3QAC | System Administrator          | Standard               |
| 00e3V000000NmeAQAS | Standard Platform User        | Standard               |
| 00e3V000000NmeZQAS | Read Only                    | Standard               |
| 00e3V000000NmeYQAS | Solution Manager             | Standard               |
| 00e3V000000NmeHQAS | Customer Community Plus User | PowerCustomerSuccess   |

Let’s assume a developer executes the query:
`SELECT Id, Name, UserType FROM Profile WHERE UserType = 'Standard'`.

Since records exist in the cache, 2 records will be returned, which is incorrect. The database contains 4 records with `UserType = 'Standard'`.
To avoid such scenarios, filtering by a unique field is required.

Sometimes, certain limitations can ensure that code functions in a deterministic and expected way. From our perspective, it is better to have limitations that make the code free from bugs and prevent unintended misuse.

### whereEqual

**Signature**

```apex title="Method Signatures"
Cacheable whereEqual(SObjectField field, Object value);
Cacheable whereEqual(String field, Object value);
```

**Example**

```apex title="SObjectField Filter Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```
```apex title="String Field Filter Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name', 'System Administrator')
    .toObject();
```

## FIELD-LEVEL SECURITY

### stripInaccessible

The `Security.stripInaccessible` method is the only one that works with cached records. Unlike `WITH USER_MODE`, which works only with SOQL, `Security.stripInaccessible` can remove inaccessible fields even from cached records.

**Signature**

```apex title="Method Signatures"
Cacheable stripInaccessible()
Cacheable stripInaccessible(AccessType accessType)
```

**Example**

```apex title="Field-Level Security Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name', 'System Administrator')
    .stripInaccessible()
    .toObject();
```

## MOCKING

### mockId

Developers can mock either the query or the cached result:
- `SOQLCache.mock('queryId').thenReturn(record);` mocks cached results.
- `SOQL.mock('queryId').thenReturn(record);` mocks the query when cached records are not found.

We generally recommend using `SOQLCache.mock('queryId').thenReturn(record);` to ensure that records from the cache are not returned, which could otherwise lead to test instability.

**Signature**

```apex title="Method Signature"
Cacheable mockId(String queryIdentifier)
```

**Example**

```apex title="Mock ID Assignment and Unit Test"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name', 'System Administrator')
    .mockId('MyQuery')
    .toObject();

// In Unit Test
SOQLCache.mock('MyQuery').thenReturn(new Profile(Name = 'Mocked System Adminstrator'));
// or
SOQL.mock('MyQuery').thenReturn(new Profile(Name = 'Mocked System Adminstrator'));
```

### record mock

**Signature**

```apex title="Method Signature"
Cacheable mock(String mockId).thenReturn(SObject record)
```

**Example**

```apex title="Record Mock Implementation"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name', 'System Administrator')
    .mockId('MyQuery')
    .toObject();

// In Unit Test
SOQLCache.mock('MyQuery).thenReturn(new Profile(Name = 'Mocked System Adminstrator'));
```

## DEBUGGING

### preview

**Signature**

```apex title="Method Signature"
Cacheable preview()
```

**Example**

```apex title="Query Preview Example"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name', 'System Administrator')
    .preview()
    .toObject();
```

Query preview will be available in debug logs:

```text title="Debug Log Output"
============ Query Preview ============
SELECT Id, Name, UserType
FROM Profile
WHERE Name = :v1
=======================================

============ Query Binding ============
{
  "v1" : "System Administrator"
}
=======================================
```

## PREDEFINIED

### byId

**Signature**

```apex title="Method Signatures"
Cacheable byId(Id recordId)
Cacheable byId(SObject record)
```

**Example**

```apex title="Filter by Record ID"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .byId('00e3V000000Nme3QAC')
    .toObject();
```

```apex title="Filter by SObject Record"
Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .byId(profile)
    .toObject();
```

## RESULT

### toId

```apex title="Method Signature"
Id toId()
```

**Example**

```apex title="Extract Single ID"
new User (
    // ...
    ProfileId = SOQLCache.of(Profile.SObjectType).whereEqual('Name', 'System Administrator').toId()
);
```

### toIdOf

**Signature**

```apex title="Method Signature"
Id toIdOf(SObjectField field)
```

**Example**

```apex title="Extract Field ID Value"
new User (
    // ...
    ProfileId = SOQLCache.of(Profile.SObjectType)
        .with(Profile.Id, Profile.Name)
        .whereEqual(Profile.Name, 'System Administrator')
        .toIdOf(Profile.Id)
);
```

### doExist

**Signature**

```apex title="Method Signature"
Boolean doExist()
```

**Example**

```apex title="Check Record Existence"
Boolean isAdminProfileExists = SOQLCache.of(Profile.SObjectType)
    .whereEqual('Name', 'System Administrator')
    .doExist();
```

### toValueOf

Extract field value from query result.
The field must be in cached fields.

**Signature**

```apex title="Method Signature"
Object toValueOf(SObjectField fieldToExtract)
```

**Example**

```apex title="Extract Field Value"
String systemAdminUserType = (String) SOQLCache.of(Profile.SObjectType).byId('00e3V000000Nme3QAC').toValueOf(Profile.UserType);
```

### toObject

When the list of records contains more than one entry, the error `List has more than 1 row for assignment to SObject` will occur.

When there are no records to assign, the error `List has no rows for assignment to SObject` will **NOT** occur. This is automatically handled by the framework, and a `null` value will be returned instead.

**Signature**

```apex title="Method Signature"
SObject toObject()
```

**Example**

```apex title="Extract Single Record"
Profile systemAdministratorProfile = (Profile) SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```
