---
sidebar_position: 90
---

# LIMIT

For more details check Check [SOQL API - LIMIT](../../api/standard-soql/soql.md#limit).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

Specify the maximum number of rows to return.

**SOQL**

```sql
SELECT Id
FROM Account
LIMIT 100
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .setLimit(100)
    .toList();
```
