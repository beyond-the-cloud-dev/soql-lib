---
sidebar_position: 20
---

# WHERE

A query requires a single condition, and that condition must filter by a unique field.

To ensure that cached records are aligned with the database, a single condition is required.
A query without a condition cannot guarantee that the number of records in the cache matches the database.

**Cached Selector**

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
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

```apex
// SELECT Id, Name, UserType
// FROM Profile
// WHERE Name = 'System Administrator'

User systemAdmin = new User(
    // ..
    ProfileId = SOQL_ProfileCache.query().byName('System Administrator').toId(),
);
```
