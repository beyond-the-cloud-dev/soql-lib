---
sidebar_position: 4
---

# FilterGroup

Create group of conditions.

## add

Allows to add multiple conditions.
Add a [`SOQL.Filter`](soql-filter.md) or [`SOQL.FilterGroup`](soql-filters-group.md).

**Signature**

```apex
FilterGroup add(FilterClause condition)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'My Account' AND NumberOfEmployees >= 10
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Name).equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
    ).toList();
```

```apex
// build conditions on fly
FilterGroup group = SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Name).equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .conditionLogic('1 OR 2');

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(group)
    ).toList();
```

## conditionLogic

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
FilterGroup conditionLogic(String order)
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
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Name).equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    ).toList();
```
