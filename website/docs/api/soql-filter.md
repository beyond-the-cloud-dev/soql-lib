---
sidebar_position: 3
---

# Filter

## predefinied
### id

- `WHERE Id = :accountId`
- `WHERE Id IN :accountIds`

**Signature**

```apex
Filter id()
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.Filter.id().equal(accountId))

SOQL.of(Account.sObjectType)
    .whereAre(SOQL.Filter.id().isIn(accountIds))
```

### recordType

- `WHERE RecordType.DeveloperName = 'Partner'`

**Signature**

```apex
Filter recordType()
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.Filter.recordType().equal('Partner'))
```

## fields
### field

Specify field that should be used in the condition.

**Signature**

```apex
Filter field(SObjectField field)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Name).equal('My Account'))
```

### relatedField

Specify parent field that should be used in the condition.

**Signature**

```apex
Filter relatedField(String relationshipPath, SObjectField field)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.relatedField('Account', Account.Name).equal('My Account'))
```

## comperators

### isNull

- `WHERE Industry = NULL`

**Signature**

```apex
Filter isNull()
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Industry).isNull())
```

### isNotNull

- `WHERE Industry != NULL`

**Signature**

```apex
Filter isNotNull()
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Industry).isNotNull())
```

### equal

- `WHERE Name = 'My Account'`
- `WHERE NumberOfEmployees = 10`
- `WHERE IsDeleted = true`

**Signature**

```apex
Filter equal(Object value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Name).equal('My Account'))

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.NumberOfEmployees).equal(10))

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.IsDeleted).equal(true))
```

### notEqual

- `WHERE Name != 'My Account'`
- `WHERE NumberOfEmployees != 10`
- `WHERE IsDeleted != true`

**Signature**

```apex
Filter notEqual(Object value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Name).notEqual('My Account'))

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.NumberOfEmployees).notEqual(10))

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.IsDeleted).notEqual(true))
```

### lessThan

- `WHERE NumberOfEmployees < 10`

**Signature**

```apex
Filter lessThan(Object value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.NumberOfEmployees).lessThan(10))
```

### greaterThan

- `WHERE NumberOfEmployees > 10`

**Signature**

```apex
Filter greaterThan(Object value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.NumberOfEmployees).greaterThan(10))
```

### lessThanOrEqual

- `WHERE NumberOfEmployees <= 10`

**Signature**

```apex
Filter lessThanOrEqual(Object value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.NumberOfEmployees).lessThanOrEqual(10))
```

### greaterThanOrEqual

- `WHERE NumberOfEmployees >= 10`

**Signature**

```apex
Filter greaterThanOrEqual(Object value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
```

### likeAny

- `WHERE Name LIKE '%My%'`

**Signature**

```apex
Filter likeAny(String value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Name).likeAny('My'))
```

### likeAnyLeft

- `WHERE Name LIKE '%My'`

**Signature**

```apex
Filter likeAnyLeft(String value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Name).likeAnyLeft('My'))
```

### likeAnyRight

- `WHERE Name LIKE 'My%'`

**Signature**

```apex
Filter likeAnyRight(String value)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Name).likeAnyRight('My'))
```

### isIn

- `WHERE Id IN :accountIds`

**Signature**

```apex
Filter isIn(List<Object> inList)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Id).isIn(accountIds))
```

### isNotIn

- `WHERE Id NOT IN :accountIds`

**Signature**

```apex
Filter isNotIn(List<Object> inList)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Id).notIn(accountIds))
```

## join query

### isIn

- `WHERE Id IN (SELECT AccountId FROM Contact WHERE Name = 'My Contact')`

**Signature**

```apex
Filter isIn(JoinQuery joinQuery)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Id).isIn(
        SOQL.InnerJoin.of(Contact.sObjectType)
            .field(Contact.AccountId)
            .whereAre(SOQL.Filter.field(Contact.Name).equal('My Contact'))
    ))
```

### isNotIn

- `WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE Name = 'My Contact')`

**Signature**

```apex
Filter isNotIn(JoinQuery joinQuery)
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.field(Account.Id).isNotIn(
        SOQL.InnerJoin.of(Contact.sObjectType)
            .field(Contact.AccountId)
            .whereAre(SOQL.Filter.field(Contact.Name).equal('My Contact'))
    ))
```
