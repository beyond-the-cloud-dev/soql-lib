---
sidebar_position: 30
---

# RESULT

For more details check [SOQLCache Cache API - RESULT](../api/soql-cache.md#result).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## toId

**Apex**

```apex title="Traditional SOQL Query"
Id adminProfileId = [
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
][0].Id;
```

**SOQL Lib**

```apex title="Cached Query - Extract ID"
Id adminProfileId = SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toId();
```

## doExist

**Apex**

```apex title="Traditional SOQL Query"
Boolean isProfileExist = ![
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
].isEmpty();
```

**SOQL Lib**

```apex title="Cached Query - Check Existence"
Boolean isProfileExist = SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .doExist();
```

## toValueOf

**Apex**

```apex title="Traditional SOQL Query"
Id profileId = [
    SELECT Id
    FROM Profile
    WHERE Name = 'System Administrator'
][0].Id;
```

**SOQL Lib**

```apex title="Cached Query - Extract Field Value"
Id profileId = (Id) SOQLCache.of(Profile.SObjectType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toValueOf(Profile.Id);
```

## toObject

**Apex**

```apex title="Traditional SOQL Query"
Profile profile = [
    SELECT Id, Name
    FROM Profile
    WHERE Name = 'System Administrator'
];
```

**SOQL Lib**

```apex title="Cached Query - Get SObject"
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInOrgCache()
    .toObject();
```

## toIdOf

Extract an ID from a specific field in the cached record:

```apex title="Cached Query - Extract ID from Field"
Id ownerId = SOQLCache.of(Account.SObjectType)
    .with(Account.Id, Account.Name, Account.OwnerId)
    .whereEqual(Account.Name, 'ACME Corp')
    .toIdOf(Account.OwnerId);
```
