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

Allows to add fields to a query.

**Signature**

```apex
QS fields(List<sObjectField> fields)
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

Allows to add parent field to a query.

**Signature**

```apex
QS relatedFields(String relationshipPath, List<sObjectField> fields)
```

**Example**

```apex
QS.of(Account.sObjectType).relatedFields('CreatedBy', List<sObjectField>{
    User.Id,
    User.Name
})

QS.of(Contact.sObjectType).relatedFields('Account', List<sObjectField>{
    Account.Id,
    Account.Name
})
```

## count

**Signature**

```apex
QS count()
```

**Example**

```apex

```

## countAs

**Signature**

```apex
countAs(sObjectField field, String alias)
```

**Example**

```apex
```

## subQuery

**Signature**

```apex
QS subQuery(QB_Sub subQuery)
```

**Example**

```apex
```

## scope

### delegatedScope

**Signature**

```apex
QS delegatedScope()
```

**Example**

```apex
```

### mineScope

**Signature**

```apex
QS mineScope()
```

**Example**

```apex
```

### mineAndMyGroupsScope

**Signature**

```apex
QS mineAndMyGroupsScope()
```

**Example**

```apex
```

### myTerritoryScope

**Signature**

```apex
QS myTerritoryScope()
```

**Example**

```apex
```

### myTeamTerritoryScope

**Signature**

```apex
QS myTeamTerritoryScope()
```

**Example**

```apex
```

### teamScope

**Signature**

```apex
QS teamScope()
```

**Example**

```apex
```

## whereAre

**Signature**

```apex
QS whereAre(QB_ConditionClause conditions)
```

**Example**

```apex
```

## group by

### groupBy

**Signature**

```apex
QS groupBy(sObjectField field)
```

**Example**

```apex
```

### groupByRollup

**Signature**

```apex
QS groupByRollup(sObjectField field)
```

**Example**

```apex
```

### groupByCube

**Signature**

```apex
QS groupByCube(sObjectField field)
```

**Example**

```apex
```

## order by

### orderBy

**Signature**

```apex
QS orderBy(sObjectField field)
```

**Example**

```apex
```

### orderByRelated

**Signature**

```apex
QS orderByRelated(String path, sObjectField field)
```

**Example**

```apex
```

### sortDesc

**Signature**

```apex
QS sortDesc()
```

**Example**

```apex
```

### nullsLast

**Signature**

```apex
QS nullsLast()
```

**Example**

```apex
```

## setLimit

**Signature**

```apex
QS setLimit(Integer amount)
```

**Example**

```apex
```

## setOffset

**Signature**

```apex
QS setOffset(Integer startingRow)
```

**Example**

```apex
```

## for

### forReference

**Signature**

```apex
QS forReference()
```

**Example**

```apex
```

### forView

**Signature**

```apex
QS forView()
```

**Example**

```apex
```

### forUpdate

**Signature**

```apex
QS forUpdate()
```

**Example**

```apex
```

### allRows

**Signature**

```apex
QS allRows()
```

**Example**

```apex
```

## fls

### systemMode

**Signature**

```apex
QS systemMode()
```

**Example**

```apex
```

## sharing

### withSharing

**Signature**

```apex
QS withSharing()
```

**Example**

```apex
```

### withoutSharing

**Signature**

```apex
QS withoutSharing()
```

**Example**

```apex
```

## mocking

**Signature**

```apex
QS mocking(String queryIdentifier)
```

**Example**

```apex
```

## preview

**Signature**

```apex
QS preview()
```

**Example**

```apex
```

## result

### asObject

**Signature**

```apex
sObject asObject()
```

**Example**

```apex
```

### asList

**Signature**

```apex
List<sObject> asList()
```

**Example**

```apex
```

### asAggregated

**Signature**

```apex
List<AggregateResult> asAggregated()
```

**Example**

```apex
```

### asInteger

**Signature**

```apex
Integer asInteger()
```

**Example**

```apex
```
