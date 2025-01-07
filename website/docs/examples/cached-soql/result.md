---
sidebar_position: 30
---

# RESULT

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
public with sharing class MyController {
    @AuraEnabled
    public static Id getProfileId(String profileName) {
        return SOQL_ProfileCache.query()
            .byName(profileName)
            .toId();
    }

    @AuraEnabled
    public static Profile getProfile(String profileName) {
        return SOQL_ProfileCache.query()
            .byName(profileName)
            .toObject();
    }
}
```
