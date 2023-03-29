---
sidebar_position: 4
---

# FiltersGroup

## add

Allows to add multiple conditions.
Add a [`QB.Filter`](qb-condition.md) or [`QB.FiltersGroup`](qb-condition-group.md).

**Signature**

```apex
FiltersGroup add(FilterClause condition)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(QB.Filter.field(Account.Name).equal('My Account'))
        .add(QB.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
    )
```

```apex
// build conditions on fly
FiltersGroup group = SOQL.FiltersGroup
        .add(QB.Filter.field(Account.Name).equal('My Account'))
        .add(QB.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .conditionLogic('1 OR 2');

SOQL.of(Account.sObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(QB.Filter.field(Account.Industry).equal('IT'))
        .add(group)
    )
```

## conditionLogic

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
FiltersGroup conditionLogic(String order)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(QB.Filter.field(Account.Name).equal('My Account'))
        .add(QB.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .add(QB.Filter.field(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    )
```
