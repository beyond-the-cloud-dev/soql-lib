---
sidebar_position: 10
---

# SELECT

Specify fields that will be retrieved via query. Check [SOQL Cache API - SELECT](../../api/cached-soql/soql-cache.md#select).

All fields specified in the `with(...)` method will be cached.
You can specify default fields to be cached in the selector's constructor.

## Cached Fields

**Cached Selector**

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

**Usage**

All default fields specified in the `SOQL_ProfileCache` constructor will be retrieved.

```apex
// SELECT Id, Name, UserType
// FROM Profile
// WHERE Name = 'System Administrator'

Profile systemAdminProfile = (Profile) SOQL_ProfileCache.query()
    .byName('System Administrator')
    .toObject();
```

You can also retrieve additional fields on the fly:

```apex
// SELECT Id, Name, UserType, UserLicenseId
// FROM Profile
// WHERE Name = 'System Administrator'

Profile systemAdminProfile = (Profile) SOQL_ProfileCache.query()
    .with(Profile.UserLicenseId)
    .byName('System Administrator')
    .toObject();
```

When the `UserLicenseId` field is not in the cache, the SOQL query will be executed, and the record in the cache will be updated with the additional field (`UserLicenseId`).
