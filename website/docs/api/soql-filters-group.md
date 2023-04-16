---
sidebar_position: 4
---

# FiltersGroup

Create group of conditions.

## add

Allows to add multiple conditions.
Add a [`SOQL.Filter`](soql-filter.md) or [`SOQL.FiltersGroup`](soql-filters-group.md).

**Signature**

```apex
FiltersGroup add(FilterClause condition)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'My Account' AND NumberOfEmployees >= 10
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(QB.Filter.with(Account.Name).equal('My Account'))
        .add(QB.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
    ).asList();
```

```apex
// build conditions on fly
FiltersGroup group = SOQL.FiltersGroup
        .add(QB.Filter.with(Account.Name).equal('My Account'))
        .add(QB.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .conditionLogic('1 OR 2');

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(QB.Filter.with(Account.Industry).equal('IT'))
        .add(group)
    ).asList();
```

## conditionLogic

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
FiltersGroup conditionLogic(String order)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE (Name = 'My Account' AND NumberOfEmployees >= 10)
OR (Name = 'My Account' AND Industry = 'IT')
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(QB.Filter.with(Account.Name).equal('My Account'))
        .add(QB.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .add(QB.Filter.with(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    ).asList();
```
