---
sidebar_position: 10
---

# SELECT

Specify fields that will be retrieved via query. Check [SOQLCache Cache API - SELECT](../api/soql-cache.md#select).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## Fields

### SObjectField fields (Recommended)

**SOQL**

```sql title="Traditional SOQL"
SELECT Id, Name, BillingCity
FROM Account
WHERE Id = '1234'
```

**SOQL Lib**

```apex title="SOQL Cache Approach"
SOQLCache.of(Account.SObject)
    .with(Account.Id, Account.Name, Account.BillingCity)
    .byId('1234')
    .toObject();
```

More than 5 fields:

**SOQL**

```sql title="Traditional SOQL"
SELECT
    Id,
    Name,
    Industry,
    Rating,
    AnnualRevenue,
    BillingCity,
    Phone
FROM Account
WHERE Id = '1234'
```

**SOQL Lib**

```apex title="SOQL Cache Approach"
SOQLCache.of(Account.SObjectType)
    .with(new List<SObjectField> {
        Account.Id,
        Account.Name,
        Account.Industry,
        Account.Rating,
        Account.AnnualRevenue,
        Account.BillingCity,
        Account.Phone
    })
    .byId('1234')
    .toObject();
```

### String fields

**SOQL**

```sql title="Traditional SOQL"
SELECT Id, Name, Industry, Rating, AnnualRevenue, BillingCity, Phone
FROM Account
WHERE Id = '1234'
```

**SOQL Lib**

```apex title="SOQL Cache Approach"
SOQLCache.of(Account.SObjectType)
    .with('Id, Name, Industry, Rating, AnnualRevenue, BillingCity, Phone')
    .byId('1234')
    .toObject();
```
