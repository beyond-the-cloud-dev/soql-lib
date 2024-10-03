---
sidebar_position: 60
---

# HavingFilter

Specify and adjust single having condition.

```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).greaterThan(1000000))
    .toAggregated();
```

## Methods

The following are methods for `HavingFilter`.

[**FIELDS**](#fields)

- [`with(SObjectField field)`](#with-sobject-field)
- [`with(String field)`](#with-string-field)
- [`count(SObjectField field)`](#count)
- [`countDistinct(SObjectField field)`](#countdistinct)
- [`min(SObjectField field)`](#min)
- [`max(SObjectField field)`](#max)
- [`sum(SObjectField field)`](#sum)

[**COMPERATORS**](#comperators)

- [`isNull()`](#isnull)
- [`isNotNull()`](#isnotnull)
- [`isTrue()`](#istrue)
- [`isFalse()`](#isfalse)
- [`equal(Object value)`](#equal)
- [`notEqual(Object value)`](#notequal)
- [`lessThan(Object value)`](#lessthan)
- [`greaterThan(Object value)`](#greaterthan)
- [`lessOrEqual(Object value)`](#lessorequal)
- [`greaterOrEqual(Object value)`](#greaterorequal)
- [`contains(String value)`](#contains)
- [`contains(String prefix, String value, String suffix)`](#contains)
- [`notContains(String value)`](#notcontains)
- [`notContains(String prefix, String value, String suffix)`](#notcontains)
- [`endsWith(String value)`](#endswith)
- [`notEndsWith(String value)`](#notendswith)
- [`startsWith(String value)`](#startswith)
- [`notStartsWith(String value)`](#notstartswith)
- [`isIn(Iterable<Object> iterable)`](#isin)
- [`notIn(Iterable<Object> iterable)`](#notin)

## FIELDS

### with sobject field

Specify field that should be used in the having condition.

**Signature**

```apex
HavingFilter with(SObjectField field)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY City
HAVING City LIKE 'San%'
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
    .toAggregated();
```

### with string field

Specify fields that should be used in the condition.

**Signature**

```apex
HavingFilter with(String field)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY City
HAVING City LIKE 'San%'
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.with('City').startsWith('San'))
    .toAggregated();
```

### count

Returns the number of rows matching the query criteria.

**Signature**

```apex
HavingFilter count(SObjectField field)
```

**Example**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
HAVING COUNT(Name) > 100
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
    .toAggregated();
```

### countDistinct

Returns the number of distinct non-null field values matching the query criteria.

**Signature**

```apex
HavingFilter countDistinct(SObjectField field)
```

**Example**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
HAVING COUNT_DISTINCT(Name) > 100
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.countDistinct(Lead.Name).greaterThan(100))
    .toAggregated();
```

### min

Returns the minimum value of a field.

**Signature**

```apex
HavingFilter min(SObjectField field)
```

**Example**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
HAVING MIN(NumberOfEmployees) > 100
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.min(Lead.NumberOfEmployees).greaterThan(100))
    .toAggregated();
```

### max

Returns the maximum value of a field.

**Signature**

```apex
HavingFilter min(SObjectField field)
```

**Example**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
HAVING MAX(NumberOfEmployees) < 100
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.max(Lead.NumberOfEmployees).lessThan(100))
    .toAggregated();
```

### sum

Returns the total sum of a numeric field.

**Signature**

```apex
HavingFilter min(SObjectField field)
```

**Example**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) > 1000000
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).greaterThan(1000000))
    .toAggregated();
```

## COMPERATORS

### isNull

- `HAVING LeadSource = NULL`

**Signature**

```apex
HavingFilter isNull()
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING LeadSource = NULL
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.with(Lead.LeadSource).isNull())
    .toAggregated();
```

### isNotNull

- `HAVING LeadSource != NULL`

**Signature**

```apex
HavingFilter isNotNull()
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING LeadSource != NULL
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.with(Lead.LeadSource).isNotNull())
    .toAggregated();
```

### isTrue

- `HAVING IsConverted = TRUE`

**Signature**

```apex
HavingFilter isTrue()
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY IsConverted
HAVING IsConverted = TRUE
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.IsConverted)
    .have(SOQL.HavingFilter.with(Lead.IsConverted).isTrue())
    .toAggregated();
```

### isFalse

- `HAVING IsConverted = FALSE`

**Signature**

```apex
HavingFilter isFalse()
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY IsConverted
HAVING IsConverted = FALSE
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.IsConverted)
    .have(SOQL.HavingFilter.with(Lead.IsConverted).isFalse())
    .toAggregated();
```

### equal

- `HAVING City = 'Los Angeles'`
- `HAVING SUM(AnnualRevenue) = 100000`

**Signature**

```apex
HavingFilter equal(Object value)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING LeadSource = 'Web'

SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) = 10000
```

```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).equal(10000))
    .toAggregated();

SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.with(Lead.LeadSource).equal('Web'))
    .toAggregated();
```

### notEqual

- `HAVING City != 'Los Angeles'`
- `HAVING SUM(AnnualRevenue) != 100000`

**Signature**

```apex
HavingFilter notEqual(Object value)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING LeadSource != 'Web'

SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) != 10000
```

```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).notEqual(10000))
    .toAggregated();

SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.with(Lead.LeadSource).notEqual('Web'))
    .toAggregated();
```

### lessThan

- `HAVING SUM(AnnualRevenue) < 10000`

**Signature**

```apex
HavingFilter lessThan(Object value)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) < 10000
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).lessThan(10000))
    .toAggregated();
```

### greaterThan

- `HAVING SUM(AnnualRevenue) > 10000`

**Signature**

```apex
HavingFilter greaterThan(Object value)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) > 10000
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).greaterThan(10000))
    .toAggregated();
```

### lessOrEqual

- `HAVING SUM(AnnualRevenue) <= 10000`

**Signature**

```apex
HavingFilter lessOrEqual(Object value)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) <= 10000
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).lessOrEqual(10000))
    .toAggregated();
```

### greaterOrEqual

- `HAVING SUM(AnnualRevenue) >= 10000`

**Signature**

```apex
HavingFilter greaterOrEqual(Object value)
```

**Example**

```sql
SELECT COUNT(Name)
FROM Lead
GROUP BY LeadSource
HAVING SUM(AnnualRevenue) >= 10000
```
```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name)
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.sum(Lead.AnnualRevenue).greaterOrEqual(10000))
    .toAggregated();
```

### contains

- `HAVING Name LIKE '%San%'`

**Signature**

```apex
HavingFilter contains(String value)
HavingFilter contains(String prefix, String value, String suffix);
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING City LIKE '%San%'
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).contains('San'))
    .toAggregated();

SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).contains('_', 'San', '%'))
    .toAggregated();
```

### notContains

- `HAVING NOT Name LIKE '%San%'`

**Signature**

```apex
HavingFilter notContains(String value)
HavingFilter notContains(String prefix, String value, String suffix);
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING (NOT City LIKE '%San%')
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).notContains('San'))
    .toAggregated();

SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).notContains('_', 'San', '%'))
    .toAggregated();
```

### startsWith

- `HAVING City LIKE 'San%'`

**Signature**

```apex
HavingFilter startsWith(String value)
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING City LIKE 'San%'
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
    .toAggregated();
```

### notStartsWith

- `HAVING NOT City LIKE 'San%'`

**Signature**

```apex
HavingFilter notStartsWith(String value)
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING (NOT City LIKE 'San%')
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).notStartsWith('San'))
    .toAggregated();
```

### endsWith

- `HAVING City LIKE '%San'`

**Signature**

```apex
HavingFilter endsWith(String value)
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING City LIKE '%San'
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).endsWith('San'))
    .toAggregated();
```

### notEndsWith

- `HAVING NOT City LIKE '%San'`

**Signature**

```apex
HavingFilter notEndsWith(String value)
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING (NOT City LIKE '%San')
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).notEndsWith('San'))
    .toAggregated();
```


### isIn

- `HAVING City IN ('San Francisco', 'Los Angeles')`

**Signature**

```apex
HavingFilter isIn(Iterable<Object> inList)
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING City IN ('San Francisco', 'Los Angeles')
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).isIn(new List<String>{ 'San Francisco', 'Los Angeles' }))
    .toAggregated();
```

### notIn

- `HAVING City NOT IN ('San Francisco', 'Los Angeles')`

**Signature**

```apex
HavingFilter notIn(Iterable<Object> inList)
```

**Example**

```sql
SELECT SUM(AnnualRevenue)
FROM Lead
GROUP BY City
HAVING City NOT IN ('San Francisco', 'Los Angeles')
```
```apex
SOQL.of(Lead.SObjectType)
    .sum(Lead.AnnualRevenue)
    .groupBy(Lead.City)
    .have(SOQL.HavingFilter.with(Lead.City).notIn(new List<String>{ 'San Francisco', 'Los Angeles' }))
    .toAggregated();
```
