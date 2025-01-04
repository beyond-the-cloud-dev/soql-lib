---
sidebar_position: 10
---

# SELECT

Specify fields that will be retrieved via query. Check [SOQL Cache API - SELECT](../../api/cached-soql/soql-cache.md#select).

All fields specified in the `with(...)` method will be cached.
You can specify default fields to be cached in the selector's constructor.

## Cached Fields

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        // default cached fields
        with(Profile.Id, Profile.Name, Profile.UserType);
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
