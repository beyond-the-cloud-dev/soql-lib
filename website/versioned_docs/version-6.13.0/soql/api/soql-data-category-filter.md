---
sidebar_position: 90
---

# DataCategoryFilter

Specify and adjust single condition.

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .aboveOrBelow('Europe__c')
    ).toList();
```

## Methods

The following are methods for `DataCategory Filter`.

[**FIELDS**](#fields)

- [`with(String field)`](#with)

[**COMPERATORS**](#comperators)

- [`at()`](#at)
- [`above()`](#above)
- [`below()`](#below)
- [`aboveOrBelow()`](#aboveorbelow)

## FIELDS
### with

**Signature**

```apex
DataCategoryFilter with(String field);
```

**Example**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE_OR_BELOW Europe__c
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .aboveOrBelow('Europe__c')
    ).toList();
```

## COMPERATORS

### at

- `WITH DATA CATEGORY Geography__c AT Europe__c`

**Signature**

```apex
DataCategoryFilter at(String category);
DataCategoryFilter at(Iterable<String> categories);
```

**Example**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c AT Europe__c
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .at('Europe__c')
    ).toList();
```

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c AT (Europe__c, North_America__c)
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .at(new List<String>{ 'Europe__c', 'North_America__c' })
    ).toList();
```

### above

- `WITH DATA CATEGORY Geography__c ABOVE Europe__c`

**Signature**

```apex
DataCategoryFilter above(String category);
DataCategoryFilter above(Iterable<String> categories);
```

**Example**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE Europe__c
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .above('Europe__c')
    ).toList();
```

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE (Europe__c, North_America__c)
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .above(new List<String>{ 'Europe__c', 'North_America__c' })
    ).toList();
```

### below

- `WITH DATA CATEGORY Geography__c BELOW Europe__c`

**Signature**

```apex
DataCategoryFilter below(String category);
DataCategoryFilter below(Iterable<String> categories);
```

**Example**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c BELOW Europe__c
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .below('Europe__c')
    ).toList();
```

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c BELOW (Europe__c, North_America__c)
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .below(new List<String>{ 'Europe__c', 'North_America__c' })
    ).toList();
```

### aboveOrBelow

- `WITH DATA CATEGORY Geography__c ABOVE_OR_BELOW Europe__c`

**Signature**

```apex
DataCategoryFilter aboveOrBelow(String category);
DataCategoryFilter aboveOrBelow(Iterable<String> categories);
```

**Example**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE_OR_BELOW Europe__c
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .aboveOrBelow('Europe__c')
    ).toList();
```

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE_OR_BELOW (Europe__c, North_America__c)
```
```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter
            .with('Geography__c')
            .aboveOrBelow(new List<String>{ 'Europe__c', 'North_America__c' })
    ).toList();
```
