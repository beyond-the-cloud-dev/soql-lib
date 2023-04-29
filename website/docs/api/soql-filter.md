---
sidebar_position: 3
---

# Filter

Specify and adjust single condition.

## predefinied
### id

- `WHERE Id = :accountId`
- `WHERE Id IN :accountIds`

**Signature**

```apex
Filter id()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id = :accountId
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.id().equal(accountId))
    .asList();
```

### recordType

- `WHERE RecordType.DeveloperName = 'Partner'`

**Signature**

```apex
Filter recordType()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE RecordType.DeveloperName = 'Partner'
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.recordType().equal('Partner'))
    .asList();
```

### Name

- `WHERE Name = 'My Account'`

**Signature**

```apex
Filter name()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'My Account'
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.name().equal('My Account'))
    .asList();
```
## fields
### with field

Specify field that should be used in the condition.

**Signature**

```apex
Filter with(SObjectField field)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'My Account'
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).equal('My Account'))
    .asList();
```

### with related field

Specify parent field that should be used in the condition.

**Signature**

```apex
Filter with(String relationshipPath, SObjectField field);
```

**Example**

```sql
SELECT Id
FROM Contact
WHERE Account.Name = 'My Account'
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with('Account', Account.Name).equal('My Account'))
    .asList();
```

## comperators

### isNull

- `WHERE Industry = NULL`

**Signature**

```apex
Filter isNull()
```

**Example**

```sql
SELECT Id
FROM Contact
WHERE Account.Industry = NULL
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).isNull())
    .asList();
```

### isNotNull

- `WHERE Industry != NULL`

**Signature**

```apex
Filter isNotNull()
```

**Example**

```sql
SELECT Id
FROM Contact
WHERE Account.Industry != NULL
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).isNotNull())
    .asList();
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

```sql
SELECT Id FROM Account WHERE Name = 'My Account'

SELECT Id FROM Account WHERE NumberOfEmployees = 10

SELECT Id FROM Account WHERE IsDeleted = true
```

```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).equal('My Account'))
    .asList();

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).equal(10))
    .asList();

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.IsDeleted).equal(true))
    .asList();
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

```sql
SELECT Id FROM Account WHERE Name != 'My Account'

SELECT Id FROM Account WHERE NumberOfEmployees != 10

SELECT Id FROM Account WHERE IsDeleted != true
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).notEqual('My Account'))
    .asList();

SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).notEqual(10))
    .asList();

SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.IsDeleted).notEqual(true))
    .asList();
```

### lessThan

- `WHERE NumberOfEmployees < 10`

**Signature**

```apex
Filter lessThan(Object value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE NumberOfEmployees < 10
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThan(10))
    .asList();
```

### greaterThan

- `WHERE NumberOfEmployees > 10`

**Signature**

```apex
Filter greaterThan(Object value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE NumberOfEmployees > 10
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThan(10))
    asList();
```

### lessThanOrEqual

- `WHERE NumberOfEmployees <= 10`

**Signature**

```apex
Filter lessThanOrEqual(Object value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE NumberOfEmployees <= 10
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThanOrEqual(10))
    .asList();
```

### greaterThanOrEqual

- `WHERE NumberOfEmployees >= 10`

**Signature**

```apex
Filter greaterThanOrEqual(Object value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE NumberOfEmployees >= 10
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10))
    .asList();
```

### likeAny

- `WHERE Name LIKE '%My%'`

**Signature**

```apex
Filter likeAny(String value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = '%My%'
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).likeAny('My'))
    .asList();
```

### likeAnyLeft

- `WHERE Name LIKE '%My'`

**Signature**

```apex
Filter likeAnyLeft(String value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = '%My'
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).likeAnyLeft('My'))
    .asList();
```

### likeAnyRight

- `WHERE Name LIKE 'My%'`

**Signature**

```apex
Filter likeAnyRight(String value)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'My%'
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).likeAnyRight('My'))
    .asList();
```

### isIn

- `WHERE Id IN :accountIds`

**Signature**

```apex
Filter isIn(List<Object> inList)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id IN :accountIds
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Id).isIn(accountIds))
    .asList();
```

### isNotIn

- `WHERE Id NOT IN :accountIds`

**Signature**

```apex
Filter isNotIn(List<Object> inList)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id NOT IN :accountIds
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Id).notIn(accountIds))
    .asList();
```

## join query

### isIn

- `WHERE Id IN (SELECT AccountId FROM Contact WHERE Name = 'My Contact')`

**Signature**

```apex
Filter isIn(JoinQuery joinQuery)
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

### isNotIn

- `WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE Name = 'My Contact')`

**Signature**

```apex
Filter isNotIn(JoinQuery joinQuery)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id NOT IN (
    SELECT AccountId
    FROM Contact
    WHERE Name = 'My Contact'
)
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Id).isNotIn(
        SOQL.InnerJoin.of(Contact.SObjectType)
            .with(Contact.AccountId)
            .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
    )).asList();
```
