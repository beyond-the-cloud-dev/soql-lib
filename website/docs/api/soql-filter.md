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
    .whereAre(SOQL.Filter.id().equal(accountId));

SOQL.of(Account.sObjectType)
    .whereAre(SOQL.Filter.id().isIn(accountIds));
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
    .whereAre(SOQL.Filter.recordType().equal('Partner'));
```

## fields
### with field

Specify field that should be used in the condition.

**Signature**

```apex
Filter with(SObjectField field)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).equal('My Account'));
```

### with related field

Specify parent field that should be used in the condition.

**Signature**

```apex
Filter with(String relationshipPath, SObjectField field);
```

**Example**

```apex
SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.with('Account', Account.Name).equal('My Account'));
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
    .whereAre(SOQL.Filter.with(Account.Industry).isNull());
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
    .whereAre(SOQL.Filter.with(Account.Industry).isNotNull());
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
    .whereAre(SOQL.Filter.with(Account.Name).equal('My Account'));

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).equal(10));

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.with(Account.IsDeleted).equal(true));
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
    .whereAre(SOQL.Filter.with(Account.Name).notEqual('My Account'));

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).notEqual(10));

SOQL.of(Contact.sObjectType)
    .whereAre(SOQL.Filter.with(Account.IsDeleted).notEqual(true));
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
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThan(10));
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
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThan(10));
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
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThanOrEqual(10));
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
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10));
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
    .whereAre(SOQL.Filter.with(Account.Name).likeAny('My'));
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
    .whereAre(SOQL.Filter.with(Account.Name).likeAnyLeft('My'));
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
    .whereAre(SOQL.Filter.with(Account.Name).likeAnyRight('My'));
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
    .whereAre(SOQL.Filter.with(Account.Id).isIn(accountIds));
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
    .whereAre(SOQL.Filter.with(Account.Id).notIn(accountIds));
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
    .whereAre(SOQL.Filter.with(Account.Id).isIn(
        SOQL.InnerJoin.of(Contact.sObjectType)
            .with(Contact.AccountId)
            .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
    ));
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
    .whereAre(SOQL.Filter.with(Account.Id).isNotIn(
        SOQL.InnerJoin.of(Contact.sObjectType)
            .with(Contact.AccountId)
            .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
    ));
```
