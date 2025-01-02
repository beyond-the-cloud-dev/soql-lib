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

[**SELECT**](#SELECT)

-

[**WHERE**](#where)

-

[**FIELD-LEVEL SECURITY**](#field-level-security)

- [`stripInaccessible()`](#stripinaccessible)
- [`stripInaccessible(AccessType accessType)`](#stripinaccessible)

[**MOCKING**](#mocking)

- [`mockId(String id)`](#mockid)

[**DEBUGGING**](#debugging)

- [`preview()`](#preview)

[**PREDEFINIED**](#predefinied)

- [`byId(SObject record)`](#byid)
- [`byId(Id recordId)`](#byid)

[**RESULT**](#result)

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

## SELECT

## WHERE

## FIELD-LEVEL SECURITY

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
