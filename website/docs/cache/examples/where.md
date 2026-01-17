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

```sql title="Standard SOQL Query"
SELECT Id, Name, UserType
FROM Profile
WHERE Name = 'System Administrator'
```

**SOQL Lib**

```apex title="Using SObjectField (Type-Safe)"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

## String

**SOQL**

```sql title="Standard SOQL Query"
SELECT Id, Name, UserType
FROM Profile
WHERE Name = 'System Administrator'
```

**SOQL Lib**

```apex title="Using String Field Name"
SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual('Name', 'System Administrator')
    .toObject();
```

## Cache Configuration Options

### allowFilteringByNonUniqueFields()

By default, cached queries can only be filtered by unique fields (`Id`, `Name`, `DeveloperName`) or fields marked as unique in the schema. This is a safety measure to ensure cache consistency. If you need to filter by non-unique fields, you can disable this validation:

```apex title="Allow Filtering by Non-Unique Fields"
SOQLCache.of(Profile.SObjectType)
    .allowFilteringByNonUniqueFields()
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.UserType, 'Standard')
    .toObject();
```

:::warning
Use `allowFilteringByNonUniqueFields()` carefully, as non-unique fields cannot guarantee that the correct records are returned from the cache.
:::

### allowQueryWithoutConditions()

By default, cached queries require at least one condition to prevent accidental retrieval of all cached records. You can disable this validation to allow queries without conditions:

```apex title="Allow Query Without Conditions"
SOQLCache.of(Profile.SObjectType)
    .allowQueryWithoutConditions()
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .toObject(); // Returns first cached record without any conditions
```

:::warning
When using `allowQueryWithoutConditions()`, the query will return the first available record from the cache if no conditions are specified.
:::

