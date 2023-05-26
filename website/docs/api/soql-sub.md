---
sidebar_position: 2
---

# SubQuery

Construct sub-query with provided API.

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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts'))
    .toList();
```

## select

### with field1 - field5

**Signature**

```apex
SubQuery with(SObjectField field);
```
```apex
SubQuery with(SObjectField field1, SObjectField field2);
```
```apex
SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3);
```
```apex
SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
```
```apex
SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
```

**Example**

```sql
SELECT Id, (
    SELECT Id, Name
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Id, Contact.Name)
    )
    .toList();
```

### with fields

Use for more than 5 fields.

**Signature**

```apex
SubQuery with(List<SObjectField> fields)
```

**Example**

```sql
SELECT Id, (
    SELECT Id, Name, Phone, RecordTypeId, Title, Salutation
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(new List<SObjectField>{
            Contact.Id,
            Contact.Name,
            Contact.Phone,
            Contact.RecordTypeId,
            Contact.Title,
            Contact.Salutation
        })
    )
    .toList();
```

### with related fields

**Signature**

```apex
SubQuery with(String relationshipName, List<SObjectField> fields)
```


**Example**

```sql
SELECT Id, (
    SELECT CreatedBy.Id, CreatedBy.Name
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with('CreatedBy', new List<SObjectField>{
            User.Id, User.Name
        })
    )
    .toList();
```

## whereAre

For more details check [`SOQL.FilterGroup`](soql-filters-group.md) and [`SOQL.Filter`](soql-filter.md)

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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .whereAre(SOQL.FilterGroup
            .add(SOQL.Filter.with(Contact.Id).equal(contactId))
            .add(SOQL.Filter.with(Contact.Name).contains('John'))
            .conditionLogic('1 OR 2')
        )
    )
    .toList();
```

## order by

**Signature**

```apex
SubQuery orderBy(SObjectField field)
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy(Contact.Name)
    )
    .toList();
```

### orderBy related

Order SOQL query by parent field.

**Signature**

```apex
SubQuery orderBy(String relationshipName, SObjectField field)
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy('CreatedBy', User.Name)
    )
    .toList();
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy(Contact.Name)
        .sortDesc()
    )
    .toList();
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .orderBy(Contact.Name)
        .nullsLast()
    )
    .toList();
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .setLimit(100)
    )
    .toList();
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .offset(10)
    )
    .toList();
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .forReference()
    )
    .toList();
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
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .forView()
    )
    .toList();
```
