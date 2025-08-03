---
sidebar_position: 95
---

# OFFSET

For more details check Check [SOQL API - OFFSET](../../api/standard-soql/soql.md#offset).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

Specify the maximum number of rows to return.

**SOQL**

```sql
SELECT Id
FROM Account
OFFSET 10
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .setOffset(10)
    .toList();
```
