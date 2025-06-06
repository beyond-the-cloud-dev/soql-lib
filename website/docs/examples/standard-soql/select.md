---
sidebar_position: 10
---

# SELECT

Specify fields that will be retrieved via query. Check [SOQL API - SELECT](../../api/standard-soql/soql.md#select).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.


## Fields

### SObjectField fields (Recommended)

**SOQL**

```sql
SELECT Id, Name, BillingCity
FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObject)
    .with(Account.Id, Account.Name, Account.BillingCity)
    .toList();
```

More than 5 fields:

**SOQL**

```sql
SELECT
    Id,
    Name,
    Industry,
    Rating,
    AnnualRevenue,
    BillingCity,
    Phone
FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(new List<SObjectField> {
        Account.Id,
        Account.Name,
        Account.Industry,
        Account.Rating,
        Account.AnnualRevenue,
        Account.BillingCity,
        Account.Phone
    })
    .toList();
```

### String fields

**SOQL**

```sql
SELECT Id, Name, Industry, Rating, AnnualRevenue, BillingCity, Phone
FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with('Id, Name, Industry, Rating, AnnualRevenue, BillingCity, Phone')
    .toList();
```

## Parent Fields

Specify relationship name and pass parent object fields. For more details check Check [SOQL API - SELECT](../../api/standard-soql/soql.md#with-related-field1---field5).

**SOQL**

```sql
SELECT
    Id, Name,
    CreatedBy.Id, CreatedBy.Name,
    Parent.Id, Parent.Name
FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with('CreatedBy', User.Id, User.Name)
    .with('Parent', Account.Id, Account.Name)
    .toList();
```
