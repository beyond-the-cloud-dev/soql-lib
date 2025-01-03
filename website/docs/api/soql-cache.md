---
sidebar_position: 15
---

# SOQL Cache

Apex Classes: `SOQLCache.cls` and `SOQLCache_Test.cls`.

The lib cache main class necessary to create cached selectors.

SOQL Cached Selector Example:

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType };
    }

    public Profile byName(String name) {
        return (Profile) whereEqual(Profile.Name, name).toObject();
    }
}
```

## Methods

The following are methods for using `SOQLCache`:


[**CACHE STORAGE**](#cache-storage)

- [`cacheInApexTransaction()`](#cacheinapextransaction)
- [`cacheInOrgCache()`](#cacheinorgcache)
- [`cacheInSessionCache()`](#cacheinsessioncache)

[**INITIAL QUERY**](#initial-query)

- [`initialQuery()`](#initialquery)

[**SELECT**](#SELECT)

- [`cachedFields()`](#cachedfields)

[**WHERE**](#where)

- [`whereEqual(SObjectField field, Object value)`](#whereequal)
- [`whereEqual(String field, Object value)`](#whereequal)

[**FIELD-LEVEL SECURITY**](#field-level-security)

- [`stripInaccessible()`](#stripinaccessible)
- [`stripInaccessible(AccessType accessType)`](#stripinaccessible)

[**MOCKING**](#mocking)

- [`mockId(String id)`](#mockid)
- [`SOQLCache.setMock(String mockId, SObject record)`](#record-mock)

[**DEBUGGING**](#debugging)

- [`preview()`](#preview)

[**PREDEFINIED**](#predefinied)

- [`byId(SObject record)`](#byid)
- [`byId(Id recordId)`](#byid)

[**RESULT**](#result)

- [`toId()`](#toid)
- [`doExist()`](#doexist)
- [`toValueOf(SObjectField fieldToExtract)`](#tovalueof)
- [`toObject()`](#toobject)

## CACHE STORAGE

### cacheInApexTransaction

**Signature**

```apex
Cacheable cacheInApexTransaction();
```

**Example**

```apex
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

```apex
Cacheable cacheInOrgCache();
```

**Example**

```apex
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

```apex
Cacheable cacheInSessionCache();
```

**Example**

```apex
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

## INITIAL QUERY

The initial query allows for the bulk population of records in the cache (if it is empty), ensuring that every subsequent query in the cached selector will use the cached records.

### initialQuery

**Signature**

```apex
SOQL.Queryable initialQuery()
```

**Example**

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInSessionCache();
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType };
    }

    public override SOQL.Queryable initialQuery() { // <=== Initial query
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
}
```

## SELECT

### cachedFields

The `SELECT` clause is determined by the `cachedFields()` method. Developers must provide all fields that should be cached. These fields are cached for the entire selector.

**Signature**

```apex
List<SObjectField> cachedFields()
```

**Example**

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInSessionCache();
    }

    public override List<SObjectField> cachedFields() { // <=== Cached Fields
        return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType };
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }
}
```

## WHERE

A cached query must include one condition. The filter must use a cached field (defined in `cachedFields()`) and should be based on `Id`, `Name`, `DeveloperName`, or another unique field.

### whereEqual

**Signature**

```apex
Cacheable whereEqual(SObjectField field, Object value);
Cacheable whereEqual(String field, Object value);
```

**Example**

```apex
SOQL_ProfileCache.query()
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

```apex
SOQL_ProfileCache.query()
    .whereEqual('Name', 'System Administrator')
    .toObject();
```

## FIELD-LEVEL SECURITY

### stripInaccessible

The `Security.stripInaccessible` method is the only one that works with cached records. Unlike `WITH USER_MODE`, which works only with SOQL, `Security.stripInaccessible` can remove inaccessible fields even from cached records.

**Signature**

```apex
Cacheable stripInaccessible()
Cacheable stripInaccessible(AccessType accessType)
```

**Example**

```apex
SOQL_ProfileCache.query()
    .byName('System Administrator')
    .stripInaccessible()
    .toObject();
```

## MOCKING

### mockId

Query needs unique id that allows for mocking.

**Signature**

```apex
Cacheable mockId(String queryIdentifier)
```

**Example**

```apex
SOQL_ProfileCache.query()
    .byName('System Administrator')
    .mockId('MyQuery')
    .toObject();

// In Unit Test
SOQLCache.setMock('MyQuery', new Profile(Name = 'Mocked System Adminstrator'));
```

### record mock

**Signature**

```apex
Cacheable setMock(String mockId, SObject record)
```

**Example**

```apex
SOQL_ProfileCache.query()
    .byName('System Administrator')
    .mockId('MyQuery')
    .toObject();

// In Unit Test
SOQLCache.setMock('MyQuery', new Profile(Name = 'Mocked System Adminstrator'));
```

## DEBUGGING

### preview

**Signature**

```apex
Cacheable preview()
```

**Example**

```apex
SOQL_ProfileCache.query()
    .byName('System Administrator')
    .preview()
    .toObject();
```

Query preview will be available in debug logs:

```
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

```apex
Cacheable byId(Id recordId)
Cacheable byId(SObject record)
```

**Example**

```apex
SOQL_ProfileCache.query()
    .byId('1234')
    .toObject();
```

```apex
Profile profle = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
SOQL_ProfileCache.query()
    .byId(profle)
    .toObject();
```

## RESULT

### toId

```apex
Id toId()
```

**Example**

```apex
Id adminProfileId = SOQL_ProfileCache.query()
    .byName('System Administrator')
    .toId();

new User (
    // ...
    ProfileId = adminProfileId
);
```

### doExist

**Signature**

```apex
Boolean doExist()
```

**Example**

```apex
Boolean isAdminProfileExists = SOQL_ProfileCache.query()
    .byName('System Administrator')
    .doExist();
```

### toValueOf

Extract field value from query result.
The field must be in cached fields.

**Signature**

```apex
Object toValueOf(SObjectField fieldToExtract)
```

**Example**

```apex
String systemAdminUserType = (String) SOQL_ProfileCache.query().byId('1234').toValueOf(Profile.UserType);
```

### toObject

When the list of records contains more than one entry, the error `List has more than 1 row for assignment to SObject` will occur.

When there are no records to assign, the error `List has no rows for assignment to SObject` will **NOT** occur. This is automatically handled by the framework, and a `null` value will be returned instead.

**Signature**

```apex
sObject toObject()
```

**Example**

```apex
Profile systemAdministratorProfile = (String) SOQL_ProfileCache.query()
    .byName('System Administrator')
    .toObject();
```
