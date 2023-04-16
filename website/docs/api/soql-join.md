---
sidebar_position: 5
---

# JoinQuery

Construct join-query and use it in condition.

## of

Conctructs an `JoinQuery`.

**Signature**

```apex
static JoinQuery of(SObjectType ofObject)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id IN (
    SELECT AccountId
    FROM Contact
    WHERE Name = 'My Contact'
)
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Id).isIn(
        SOQL.InnerJoin.of(Contact.SObjectType)
            .with(Contact.AccountId)
    )).asList();
```

## field

> `SELECT` statement that specifies the fields to query.

**Signature**

```apex
static JoinQuery with(SObjectField field)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id IN (
    SELECT AccountId
    FROM Contact
)
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Id).isIn(
        SOQL.InnerJoin.of(Contact.SObjectType)
            .with(Contact.AccountId)
    )).asList();
```

## whereAre

> The condition expression in a `WHERE` clause of a SOQL query includes one or more field expressions. You can specify multiple field expressions in a condition expression by using logical operators.

For more details check [`SOQL.FiltersGroup`](soql-filters-group.md) and [`SOQL.Filter`](soql-filter.md)

**Signature**

```apex
static JoinQuery whereAre(FiltersGroup conditions)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id IN (
    SELECT AccountId
    FROM Contact
    WHERE Name = 'My Contact'
)
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Id).isIn(
        SOQL.InnerJoin.of(Contact.SObjectType)
            .with(Contact.AccountId)
            .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
    )).asList();
```
