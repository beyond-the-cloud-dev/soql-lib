---
sidebar_position: 1
---

# QS

## of

Conctructs an `QS`.

**Signature**

```apex
static QS of(sObjectType ofObject)
```

**Example**

```apex
QS.of(Account.sObjectType)
QS.of(Contact.sObjectType)
```

## fields

Allows to add fields to query.

**Signature**

```apex
static QS fields(List<sObjectField> fields)
```

**Example**

```apex
QS.of(Account.sObjectType).fields(List<sObjectField>{
    Account.Id,
    Account.Name,
    Account.Industry
})

QS.of(Contact.sObjectType).fields(List<sObjectField>{
    Contact.Id,
    Contact.FirstName,
    Contact.LastName
})
```

## relatedFields

## count

## countAs

## subQuery

## scope

### delegatedScope

### mineScope

### mineAndMyGroupsScope

### myTerritoryScope

### myTeamTerritoryScope

### teamScope

## whereAre

## group by

### groupBy

### groupByRollup

### groupByCube

## order by

### orderBy

### orderByRelated

### sortDesc

### nullsLast

## setLimit

## setOffset

## for

### forReference

### forView

### forUpdate

### allRows

## fls

### systemMode

## sharing

### withSharing

### withoutSharing

## mocking

## preview

## result

### asObject

### asList

### asAggregated

### asInteger
