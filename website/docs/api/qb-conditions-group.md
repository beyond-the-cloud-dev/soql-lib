---
sidebar_position: 3
---

# QB_ConditionsGroup

## add

Allows to add multiple conditions.
Add a [`QB.Condition`](qb-condition.md) or [`QB.ConditionsGroup`](qb-condition-group.md).

**Signature**

```apex
QB_ConditionsGroup add(QB_ConditionClause condition)
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.ConditionsGroup
        .add(QB.Condition.field(Account.Name).equal('My Account'))
        .add(QB.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
    )
```

```apex
// build conditions on fly
QB_ConditionsGroup group = QS.ConditionsGroup
        .add(QB.Condition.field(Account.Name).equal('My Account'))
        .add(QB.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .order('1 OR 2');

QS.of(Account.sObjectType)
    .whereAre(QS.ConditionsGroup
        .add(QB.Condition.field(Account.Industry).equal('IT'))
        .add(group)
    )
```

## order

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
QB_ConditionsGroup order(String order)
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.ConditionsGroup
        .add(QB.Condition.field(Account.Name).equal('My Account'))
        .add(QB.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
        .add(QB.Condition.field(Account.Industry).equal('IT'))
        .order('(1 AND 2) OR (1 AND 3)')
    )
```
