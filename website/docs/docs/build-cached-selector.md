---
sidebar_position: 18
---

# Building Cached Selector

Check examples in the [repository](https://github.com/beyond-the-cloud-dev/soql-lib/tree/main/force-app/main/default/classes/examples/cached-selectors).


SOQL-Lib is agile, so you can adjust the solution according to your needs.
We don't force one approach over another; you can choose your own. Here are our suggestions:

## A - Inheritance - extends SOQLCache, implements Interface + static (Recommended)

In this configuration, you can specify default fields, the cache storage type `cacheIn...` (Org Cache, Session Cache, or Apex transaction), and the time in hours before a refresh is required (`maxHoursWithoutRefresh`). Additionally, you can add an `initialQuery()` to prepopulate records in the cache, ensuring that subsequent queries retrieve records from the prepopulated set.

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        maxHoursWithoutRefresh(48);
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
