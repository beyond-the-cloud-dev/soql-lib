---
sidebar_position: 4
---

# QB_Condition

## predefinied
### id

- `WHERE Id = :accountId`
- `WHERE Id IN :accountIds`

**Signature**

```apex
QB_Condition id()
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.Condition.id().equal(accountId))

QS.of(Account.sObjectType)
    .whereAre(QS.Condition.id().inCollection(accountIds))
```

### recordTypeDeveloperName

- `WHERE RecordType.DeveloperName = 'Partner'`

**Signature**

```apex
QB_Condition recordTypeDeveloperName()
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.Condition.recordTypeDeveloperName().equal('Partner'))
```

## fields
### field

Specify field that should be used in the condition.

**Signature**

```apex
QB_Condition field(SObjectField field)
```

**Example**

```apex
QS.of(Account.sObjectType)
    .whereAre(QS.Condition.field(Account.Name).equal('My Account'))
```

### relationship

Specify parent field that should be used in the condition.

**Signature**

```apex
QB_Condition relationship(String relationshipPath, SObjectField field)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.relationship('Account', Account.Name).equal('My Account'))
```

## comperators

### isNull

- `WHERE Industry = NULL`

**Signature**

```apex
QB_Condition isNull()
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Industry).isNull())
```

### isNotNull

- `WHERE Industry != NULL`

**Signature**

```apex
QB_Condition isNotNull()
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Industry).isNotNull())
```

### equal

- `WHERE Name = 'My Account'`
- `WHERE NumberOfEmployees = 10`
- `WHERE IsDeleted = true`

**Signature**

```apex
QB_Condition equal(Object value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Name).equal('My Account'))

QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.NumberOfEmployees).equal(10))

QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.IsDeleted).equal(true))
```

### notEqual

- `WHERE Name != 'My Account'`
- `WHERE NumberOfEmployees != 10`
- `WHERE IsDeleted != true`

**Signature**

```apex
QB_Condition notEqual(Object value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Name).notEqual('My Account'))

QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.NumberOfEmployees).notEqual(10))

QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.IsDeleted).notEqual(true))
```

### lessThan

- `WHERE NumberOfEmployees < 10`

**Signature**

```apex
QB_Condition lessThan(Object value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThan(10))
```

### greaterThan

- `WHERE NumberOfEmployees > 10`

**Signature**

```apex
QB_Condition greaterThan(Object value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThan(10))
```

### lessThanOrEqual

- `WHERE NumberOfEmployees <= 10`

**Signature**

```apex
QB_Condition lessThanOrEqual(Object value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThanOrEqual(10))
```

### greaterThanOrEqual

- `WHERE NumberOfEmployees >= 10`

**Signature**

```apex
QB_Condition greaterThanOrEqual(Object value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
```

### likeAnyBoth

- `WHERE Name LIKE '%My%'`

**Signature**

```apex
QB_Condition likeAnyBoth(String value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Name).likeAnyBoth('My'))
```

### likeAnyLeft

- `WHERE Name LIKE '%My'`

**Signature**

```apex
QB_Condition likeAnyLeft(String value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Name).likeAnyLeft('My'))
```

### likeAnyRight

- `WHERE Name LIKE 'My%'`

**Signature**

```apex
QB_Condition likeAnyRight(String value)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Name).likeAnyRight('My'))
```

### inCollection

- `WHERE Id IN :accountIds`

**Signature**

```apex
QB_Condition inCollection(List<Object> inList)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Id).inCollection(accountIds))
```

### notIn

- `WHERE Id NOT IN :accountIds`

**Signature**

```apex
QB_Condition notIn(List<Object> inList)
```

**Example**

```apex
QS.of(Contact.sObjectType)
    .whereAre(QS.Condition.field(Account.Id).notIn(accountIds))
```
