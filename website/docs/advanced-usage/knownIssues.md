---
sidebar_position: 40
---

# Known Issues

## Variable does not exist

Error: `System.QueryException: Variable does not exist: v1`

### Root Cause

This is **NOT** the lib issue but rather a Salesforce platform limitation that occurs when `Database.getQueryLocatorWithBinds` is used with insufficient permissions.

This error occurs when all of the following conditions are met:
- `toQueryLocator()` is executed
- Query is executed with `USER_MODE` (which is the default mode if not otherwise specified)
- Query contains fields to which the user doesn't have access
- Query has at least one condition, which means that a binding map is used

**Example that fails:**

**Apex**

```apex
Database.getQueryLocatorWithBinds(
    'SELECT Type FROM Task WHERE Type != :v1', 
    new Map<String, Object>{'v1' => null}, 
    AccessLevel.USER_MODE
);
```

**SOQL Lib**

```apex
SOQL.of(Task.SObjectType)
    .with(Task.Type) // <== no access to this field
    .whereAre(SOQL.Filter.with(Task.Type).isNotNull())
    .toQueryLocator();
```

### Solutions

#### Ensure user has field access permissions

Grant the user appropriate field-level security permissions for the fields used in the query.

#### Use SYSTEM_MODE

**Apex**
```apex
Database.getQueryLocatorWithBinds(
    'SELECT Type FROM Task WHERE Type != :v1', 
    new Map<String, Object>{'v1' => null}, 
    AccessLevel.SYSTEM_MODE
);
```

**SOQL Lib**

```apex
SOQL.of(Task.SObjectType)
    .with(Task.Type) 
    .whereAre(SOQL.Filter.with(Task.Type).isNotNull())
    .systemMode()
    .toQueryLocator();
```
