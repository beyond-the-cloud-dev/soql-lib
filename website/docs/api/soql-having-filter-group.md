---
sidebar_position: 70
---

# HavingFilterGroup

Create group of having conditions.

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name)
    .groupBy(Lead.City)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilterGroup
        .add(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
        .add(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
    )
    .toAggregated();
```


## Methods

The following are methods for `HavingFilterGroup`.

[**ADD CONDITION**](#add-condition)

- [`add(HavingFilterGroup havingFilterGroup)`](#add)
- [`add(HavingFilter havingFilter)`](#add)
- [`add(String dynamicCondition)`](#add)

[**ORDER**](#order)

- [`anyConditionMatching()`](#anyconditionmatching)
- [`conditionLogic(String order)`](#conditionlogic)

## ADD CONDITION
### add

Allows to add multiple conditions.
Add a [`SOQL.HavingFilter`](soql-having-filter.md) or [`SOQL.HavingFilterGroup`](soql-having-filter-group.md) or `String`.

**Signature**

```apex
HavingFilterGroup add(HavingFilterGroup havingFilterGroup)
HavingFilterGroup add(HavingFilter havingFilter)
HavingFilterGroup add(String dynamicCondition)
```

**Example**

```sql
SELECT LeadSource, COUNT(Name)
FROM Lead
GROUP BY LeadSource, City
HAVING (COUNT(Name) > 100 AND City LIKE 'San%')
```

```apex
// build conditions on fly
SOQL.HavingFilterGroup havingFilterGroup = SOQL.HavingFilterGroup
    .add(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
    .add(SOQL.HavingFilter.with(Lead.City).startsWith('San'));

SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .groupBy(Lead.City)
    .have(havingFilterGroup)
    .toAggregated();
```

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilterGroup
        .add(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
        .add(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
    ).toAggregated();
```

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have('(COUNT(Name) > 100 AND COUNT(Name) < 200)')
    .have(SOQL.HavingFilterGroup
        .add(SOQL.HavingFilter.count(Lead.Name).greaterThan(400))
        .add(SOQL.HavingFilter.count(Lead.Name).lessThan(500))
    ).toAggregated();
```

## ORDER
### conditionLogic

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
HavingFilterGroup conditionLogic(String order)
```

**Example**

```sql
SELECT LeadSource, COUNT(Name)
FROM Lead
GROUP BY LeadSource, City
HAVING (COUNT(Name) > 100 OR City LIKE 'San%')
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilterGroup
        .add(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
        .add(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
        .conditionLogic('1 OR 2')
    ).toAggregated();
```

### anyConditionMatching

When the [conditionLogic](#conditionlogic) is not specified, all conditions are joined using the `AND` operator by default.

To change the default condition logic, you can utilize the `anyConditionMatching` method, which joins conditions using the `OR` operator.

**Signature**

```apex
HavingFilterGroup anyConditionMatching()
```

**Example**

```sql
SELECT LeadSource, COUNT(Name)
FROM Lead
GROUP BY LeadSource, City
HAVING (COUNT(Name) > 100 OR City LIKE 'San%')
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilterGroup
        .add(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
        .add(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
        .anyConditionMatching()
    ).toAggregated();
```
