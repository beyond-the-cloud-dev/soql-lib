---
sidebar_position: 110
---

# FIELD-LEVEL SECURITY

For more details check [SOQL API - FIELD-LEVEL SECURITY](../api/soql.md#field-level-security) and [Advanced - FIELD-LEVEL SECURITY](../advanced/fls.md)

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## WITH USER_MODE

`USER_MODE` is a default option.

**SOQL**

```sql
SELECT Id
FROM Account
WITH USER_MODE
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .toList();
```

or explicitly:

```apex
SOQL.of(Account.SObjectType)
    .userMode()
    .toList();
```

## WITH SYSTEM_MODE

You can set `SYSTEM_MODE` for all queries by adding `.systemMode()` to selector class.

**SOQL**

```sql
SELECT Id
FROM Account
WITH SYSTEM_MODE
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .systemMode()
    .toList();
```

## stripInaccessible

`USER_MODE` enforces not only object and field-level security but also sharing rules (`with sharing`). You may encounter situations where you need object and field-level security but want to ignore sharing rules (`without sharing`). To achieve this, use `.systemMode()`, `.withoutSharing()` and `.stripInaccessible()`.

**SOQL**

```apex
SELECT Id
FROM Account
WITH SYSTEM_MODE
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .systemMode()
    .withoutSharing()
    .stripInaccessible()
    .toList();
```
