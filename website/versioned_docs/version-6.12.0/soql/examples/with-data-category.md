---
sidebar_position: 75
---

# WITH DATA_CATEGORY

Use [SOQL.DataCategoryFilter](../api/soql-data-category-filter.md) to build your `WITH DATA_CATEGORY` clause.

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## AT

**SOQL**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c AT Europe__c
```

**SOQL Lib**

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter.with('Geography__c').at('Europe__c')
    ).toList();
```

## ABOVE

**SOQL**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE Europe__c
```

**SOQL Lib**

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter.with('Geography__c').above('Europe__c')
    ).toList();
```

## BELOW

**SOQL**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c BELOW Europe__c
```

**SOQL Lib**

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter.with('Geography__c').below('Europe__c')
    ).toList();
```

## ABOVE_OR_BELOW

**SOQL**

```sql
SELECT Id, Title
FROM Knowledge__kav
WITH DATA CATEGORY Geography__c ABOVE_OR_BELOW Europe__c
```

**SOQL Lib**

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(
        SOQL.DataCategoryFilter.with('Geography__c').aboveOrBelow('Europe__c')
    ).toList();
```
