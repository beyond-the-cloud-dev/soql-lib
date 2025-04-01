---
sidebar_position: 30
---

# RESULT

For more details check [SOQLCache Cache API - RESULT](../../api/cached-soql/soql-cache.md#result).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## toId

**Apex**

```apex
Id adminProfileId = [
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
][0].Id;
```

**SOQL Lib**

```apex
Id adminProfileId = SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toId();
```

## doExist

**Apex**

```apex
Boolean adminProfileId = ![
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
].isEmpty();
```

**SOQL Lib**

```apex
Boolean isProfileExist = SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .doExist();
```

## toValueOf

**Apex**

```apex
Id profileId = [
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
][0].Id;
```

**SOQL Lib**

```apex
Id profileId = (Id) SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toValueOf(Profile.Id);
```

## toObject

**Apex**

```apex
Profile profile = [
    SELECT Id, Name
    FROM Profile
    WHERE Name = 'System Administrator'
];
```

**SOQL Lib**

```apex
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInOrgCache()
    .toObject()
```
