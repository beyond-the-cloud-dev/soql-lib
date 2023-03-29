---
sidebar_position: 5
---

# JoinQuery

## of

Conctructs an `JoinQuery`.

**Signature**

```apex
static JoinQuery of(sObjectType ofObject)
```

**Example**

```apex
SOQL.InnerJoin.of(Account.sObjectType)
SOQL.InnerJoin.of(Contact.sObjectType)
```

## field

> `SELECT` statement that specifies the fields to query.

**Signature**

```apex
static JoinQuery field(sObjectField field)
```

**Example**

```apex
SOQL.InnerJoin.of(Contact.sObjectType).field(Contact.Account.Id)
```

## whereAre

> The condition expression in a `WHERE` clause of a SOQL query includes one or more field expressions. You can specify multiple field expressions in a condition expression by using logical operators.

For more details check [`QB.FiltersGroup`](qb-conditions-group.md) and [`QB.Filter`](qb-conition.md)

**Signature**

```apex
static JoinQuery whereAre(FiltersGroup conditions)
```

**Example**

```apex
SOQL.InnerJoin.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Contact.Name).equal('My Contact'))
```
