---
sidebar_position: 10
---

# Getting Started

The SOQL Cache module of the SOQL Lib consists of two concepts: **SOQL Cache Builder** and **SOQL Cached Selectors**.

## SOQL Cache Builder

Our library allows you to cache SOQL query results to improve performance. Queries can be built directly via fluent API provided by the cache module.

```apex
// Cache query results in Apex Transaction Cache
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInOrgCache()
    .toObject();
```

## SOQL Cached Selectors _(Recommended)_

However, we recommend building cached selectors per `SObjectType`. 

Cached selectors allow you to set default caching configurations for a given `SObjectType` and keep all reusable cached queries in one place.
Check how to build a cached selector in the [Build Cached Selector](./build-cached-selector.md) section.

```apex title="SOQL_CachedProfile.cls"
public inherited sharing class SOQL_CachedProfile extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedProfile query() {
        return new SOQL_CachedProfile();
    }

    private SOQL_CachedProfile() {
        super(Profile.SObjectType);
        // default settings
        with(Profile.Id, Profile.Name, Profile.UserType)
            .cacheInOrgCache()
            .maxHoursWithoutRefresh(36);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType);
    }

    public SOQL_CachedProfile byName(String profileName) {
        whereEqual(Profile.Name, profileName);
        return this;
    }
}
```

```apex title="Cached Selector Usage"
Profile adminProfile = (Profile) SOQL_CachedProfile.query()
    .byName('System Administrator')
    .toObject();

String userType = (String) SOQL_CachedProfile.query()
    .byName('System Administrator')
    .toValueOf(Profile.UserType);
```
