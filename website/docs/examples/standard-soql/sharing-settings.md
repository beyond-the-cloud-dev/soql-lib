---
sidebar_position: 12
---

# SHARING MODE

For more details check Check [SOQL API - SHARING MODE](../../api/standard-soql/soql.md#sharing-mode) and [Advanced - SHARING MODE](../../advanced-usage/sharing.md)

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## with sharing

`with sharing` is a default option option, because of `USER_MODE`. You can control sharing rules only in `.systemMode()`.

### WITH USER_MODE

No action needed.

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

or explicity:

```apex
SOQL.of(Account.SObjectType)
    .userMode()
    .toList();
```

### WITH SYSTEM_MODE

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
    .withSharing()
    .toList();
```

## without sharing

You have to use on `WITH SYSTEM_MODE` `.systemMode()` to use `withoutSharing()`.

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
    .withoutSharing()
    .toList();
```
