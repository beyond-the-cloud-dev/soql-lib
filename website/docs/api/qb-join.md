---
sidebar_position: 5
---

# JoinQuery

## of

Conctructs an `QB_Join`.

**Signature**

```apex
static QB_Join of(sObjectType ofObject)
```

**Example**

```apex
QS.Join.of(Account.sObjectType)
QS.Join.of(Contact.sObjectType)
```

## field

> `SELECT` statement that specifies the fields to query.

**Signature**

```apex
static QB_Join field(sObjectField field)
```

**Example**

```apex
QS.Join.of(Contact.sObjectType).field(Contact.Account.Id)
```

## where

> The condition expression in a `WHERE` clause of a SOQL query includes one or more field expressions. You can specify multiple field expressions in a condition expression by using logical operators.

For more details check [`QB.FiltersGroup`](qb-conditions-group.md) and [`QB.Filter`](qb-conition.md)

**Signature**

```apex
static QB_Join whereAre(QB_ConditionsGroup conditions)
```

**Example**

```apex
QS.Join.of(Contact.sObjectType)
    .whereAre(QS.Filter.field(Contact.Name).equal('My Contact'))
```
