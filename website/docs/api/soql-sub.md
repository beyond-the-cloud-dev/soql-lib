---
sidebar_position: 2
---

# SubQuery

## of

Conctructs an `SubQuery`.

**Signature**

```apex
SubQuery of(String ofObject)
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts'))
    .asList();
```

## select

### with field

**Signature**

```apex
SOQL with(sObjectField field)
```

**Example**

```sql
SELECT Id, (
    SELECT Name
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Name)
    )
    .asList();
```

### with fields

**Signature**

```apex
SubQuery with(List<sObjectField> fields)
```

**Example**

```sql
SELECT Id, (
    SELECT Id, Name
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(new List<sObjectField>{
            Contact.Id, Contact.Name
        })
    )
    .asList();
```

### with related fields

**Signature**

```apex
SubQuery with(String relationshipName, List<sObjectField> fields)
```


**Example**

```sql
SELECT Id, (
    SELECT CreatedBy.Id, CreatedBy.Name
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with('CreatedBy',
            User.Id, User.Name
        })
    )
    .asList();
```

## whereAre

For more details check [`SOQL.FiltersGroup`](soql-filters-group.md) and [`SOQL.Filter`](soql-filter.md)

**Signature**

```apex
SubQuery whereAre(FilterClause conditions)
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    WHERE Id = :contactId OR Name = '%John%'
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .whereAre(SOQL.FiltersGroup
            .add(SOQL.Filter.with(Contact.Id).equal(contactId))
            .add(SOQL.Filter.with(Contact.Name).likeAny('John'))
            .conditionLogic('1 OR 2')
        )
    )
    .asList();
```

## order by

**Signature**

```apex
SubQuery orderBy(sObjectField field)
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    ORDER BY Name
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy(Contact.Name)
    )
    .asList();
```

### orderBy related

Order SOQL query by parent field.

**Signature**

```apex
SubQuery orderBy(String relationshipName, sObjectField field)
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    ORDER BY CreatedBy.Name
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy('CreatedBy', User.Name)
    )
    .asList();
```

### sortDesc

Default order is ascending (`ASC`).

**Signature**

```apex
SubQuery sortDesc()
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    ORDER BY Name DESC
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy(Contact.Name)
        .sortDesc()
    )
    .asList();
```

### nullsLast

By default, null values are sorted first (`NULLS FIRST`).

**Signature**

```apex
SubQuery nullsLast()
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    ORDER BY Name NULLS LAST
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy(Contact.Name)
        .nullsLast()
    )
    .asList();
```

## setLimit


**Signature**

```apex
SubQuery setLimit(Integer amount)
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    LIMIT 100
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .setLimit(100)
    )
    .asList();
```

## offset

**Signature**

```apex
SubQuery offset(Integer startingRow)
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    OFFSET 10
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .offset(10)
    )
    .asList();
```

## for

### forReference

**Signature**

```apex
SubQuery forReference()
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    FOR REFERENCE
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .forReference()
    )
    .asList();
```

### forView

**Signature**

```apex
SubQuery forView()
```

**Example**

```sql
SELECT Id, (
    SELECT Id
    FROM Contacts
    FOR VIEW
) FROM Account
```
```apex
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .forView()
    )
    .asList();
```
