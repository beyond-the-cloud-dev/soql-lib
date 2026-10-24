---
sidebar_position: 140
---

# DEBUGGING

For more details check Check [SOQL API - DEBUGGING](../api/soql.md#debugging).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

See query String in debug logs.

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(
        Account.Id,
        Account.Name,
        Account.BillingCity,
        Account.BillingCountry,
        Account.BillingCountryCode
    )
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.id().equal('0013V00000WNCw4QAH'))
        .add(SOQL.Filter.name().contains('Test'))
        .anyConditionMatching()
    )
    .preview()
    .toList();
```

You will see in debug logs:

```
============ Query Preview ============
SELECT Id, Name, BillingCity, BillingCountry, BillingCountryCode
FROM Account
WHERE (Id = :v1 OR Name LIKE :v2)
=======================================

============ Query Binding ============
{
  "v2" : "%Test%",
  "v1" : "0013V00000WNCw4QAH"
}
=======================================
```
