---
sidebar_position: 20
---

# WHERE

For more details check [SOQLCache Cache API - WHERE](../api/soql-cache.md#where).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## SObjectField (Recommended)

**SOQL**

```sql
SELECT Id, Name, UserType
FROM Profile
WHERE Name = 'System Administrator'
```

**SOQL Lib**

```apex
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

## String

**SOQL**

```sql
SELECT Id, Name, UserType
FROM Profile
WHERE Name = 'System Administrator'
```

**SOQL Lib**

```apex
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name;, 'System Administrator')
    .toObject();
```
