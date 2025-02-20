---
sidebar_position: 20
---

# SubQuery

Construct sub-query with provided API.

```apex
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Id, Contact.Name, Contact.Phone)
    )
    .toList();
```

## Methods

The following are methods for `SubQuery`.

[**INIT**](#init)

- [`of(String ofObject)`](#of)

[**SELECT**](#select)

- [`with(SObjectField field)`](#with-fields)
- [`with(SObjectField field1, SObjectField field2)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#with-field1---field5)
- [`with(List<SObjectField> fields)`](#with-fields)
- [`with(String relationshipName, Iterable<SObjectField> fields)`](#with-related-fields)
- [`with(String fields)`](#with-string-fields)

[**SUBQUERY**](#sub-query)

- [`with(SubQuery subQuery)`](#with-subquery)

[**WHERE**](#where)

- [`whereAre(FilterGroup filterGroup)`](#whereare)
- [`whereAre(Filter filter)`](#whereare)

[**ORDER BY**](#order-by)

- [`orderBy(SObjectField field)`](#order-by)
- [`orderBy(String field)`](#orderby-string-field)
- [`orderBy(String relationshipName, SObjectField field)`](#orderby-related)
- [`sortDesc()`](#sortdesc)
- [`sort(String direction)`](#sort)
- [`nullsLast()`](#nullslast)

[**LIMIT**](#limit)

- [`setLimit(Integer amount)`](#setlimit)

[**OFFSET**](#offset)

- [`offset(Integer startingRow)`](#offset)

[**FOR**](#for)

- [`forReference()`](#forreference)
- [`forView()`](#forview)

## INIT
### of

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

## SELECT

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
SubQuery with(String relationshipName, Iterable<SObjectField> fields)
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

### with string fields

**Signature**

```apex
SubQuery with(String fields)
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
        .with('Id, Name, Phone, RecordTypeId, Title, Salutation')
    )
    .toList();
```

## SUB-QUERY
### with subquery

[Query Five Levels of Parent-to-Child Relationships in SOQL Queries](https://help.salesforce.com/s/articleView?id=release-notes.rn_api_soql_5level.htm&release=244&type=5)

> Use SOQL to query several relationship types.

**Signature**

```apex
SubQuery with(SOQL.SubQuery subQuery)
```

**Example**

```sql
SELECT Name, (
    SELECT LastName , (
        SELECT AssetLevel FROM Assets
    ) FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.LastName)
        .with(SOQL.SubQuery.of('Assets')
            .with(Asset.AssetLevel)
        )
    ).toList();
```

## WHERE
### whereAre

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

## ORDER BY
### order by

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

### orderBy string field

**Signature**

```apex
SubQuery orderBy(String field)
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
        .orderBy('Name')
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

### sort

**Signature**

```apex
SubQuery sort(String direction)
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
        .orderBy('Name')
        .sort('DESC')
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

## LIMIT
### setLimit


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

## OFFSET
### offset

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

## FOR

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
