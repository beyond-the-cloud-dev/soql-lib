---
sidebar_position: 4
---

# FiltersGroup

## add

Allows to add multiple conditions.
Add a [`QB.Filter`](qb-condition.md) or [`QB.FiltersGroup`](qb-condition-group.md).

**Signature**

```apex
QB_ConditionsGroup add(QB_ConditionClause condition)
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.FiltersGroup
        .add(QB.Filter.field(Account.Name).equal('My Account'))
        .add(QB.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
    )
```

```apex
// build conditions on fly
QB_ConditionsGroup group = QS.FiltersGroup
        .add(QB.Filter.field(Account.Name).equal('My Account'))
        .add(QB.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .conditionLogic('1 OR 2');

QS.of(Account.sObjectType)
    .whereAre(QS.FiltersGroup
        .add(QB.Filter.field(Account.Industry).equal('IT'))
        .add(group)
    )
```

## order

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
QB_ConditionsGroup conditionLogic(String order)
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.FiltersGroup
        .add(QB.Filter.field(Account.Name).equal('My Account'))
        .add(QB.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .add(QB.Filter.field(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    )
```
