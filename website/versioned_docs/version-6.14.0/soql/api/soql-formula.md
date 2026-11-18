---
sidebar_position: 35
---

# Formula

Filter records on the sum or the difference of two fields with the `FORMULA()` function.

```apex
SOQL.of(Opportunity.SObjectType)
    .whereAre(SOQL.Formula('Amount - ExpectedRevenue').greaterThan(100))
    .toList();
```

:::warning[Beta]
[`FORMULA()`](https://developer.salesforce.com/docs/platform/salesforce-soql-sosl/guide/sforce-api-calls-soql-select-formula.html) in a `WHERE` clause is a Salesforce Beta feature. It works only in Developer Edition, scratch, and sandbox orgs, from API version 68.0 (Winter '27).
:::

Salesforce accepts:

- **two fields** joined by `+` or `-`, for example `'Amount - ExpectedRevenue'` or `'Account.AnnualRevenue - Amount'`. Literals, functions, and a third field are rejected.
- **Number, Currency, Percent, Date, and DateTime fields**. Date and DateTime fields can't be mixed. Subtracting two dates gives the number of days between them.
- **`WHERE` only**. A formula can be used wherever a [`SOQL.Filter`](soql-filter.md) can: in `whereAre`, in a [`SOQL.FilterGroup`](soql-filters-group.md), in a [`SOQL.SubQuery`](soql-sub.md), and in a [`SOQL.InnerJoin`](soql-join.md). It's not supported in `HAVING`, `ORDER BY`, or `SELECT`.

`FORMULA()` doesn't accept bind variables, so the value is written into the query. That's why the comparators take a `Decimal` or a `Date` instead of an `Object`.

## Methods

The following are methods for `Formula`.

[**INIT**](#init)

- [`Formula(String formula)`](#formula-string)

[**COMPARATORS**](#comparators)

- [`equal(Decimal value)`](#equal)
- [`equal(Date value)`](#equal)
- [`notEqual(Decimal value)`](#notequal)
- [`notEqual(Date value)`](#notequal)
- [`lessThan(Decimal value)`](#lessthan)
- [`lessThan(Date value)`](#lessthan)
- [`lessOrEqual(Decimal value)`](#lessorequal)
- [`lessOrEqual(Date value)`](#lessorequal)
- [`greaterThan(Decimal value)`](#greaterthan)
- [`greaterThan(Date value)`](#greaterthan)
- [`greaterOrEqual(Decimal value)`](#greaterorequal)
- [`greaterOrEqual(Date value)`](#greaterorequal)

[**ADDITIONAL**](#additional)

- [`ignoreWhen(Boolean logicExpression)`](#ignorewhen)

## INIT
### Formula string

Construct a `FORMULA()` condition from two fields joined by `+` or `-`.

**Signature**

```apex
Formula Formula(String formula)
```

**Example**

```sql
SELECT Id
FROM Opportunity
WHERE FORMULA('Account.AnnualRevenue - Amount') < 0
```
```apex
SOQL.of(Opportunity.SObjectType)
    .whereAre(SOQL.Formula('Account.AnnualRevenue - Amount').lessThan(0))
    .toList();
```

## COMPARATORS
### equal

- `WHERE FORMULA('Amount - ExpectedRevenue') = 0`

**Signature**

```apex
Formula equal(Decimal value)
Formula equal(Date value)
```

**Example**

```sql
SELECT Id
FROM Opportunity
WHERE FORMULA('Amount - ExpectedRevenue') = 0
```
```apex
SOQL.of(Opportunity.SObjectType)
    .whereAre(SOQL.Formula('Amount - ExpectedRevenue').equal(0))
    .toList();
```

### notEqual

- `WHERE FORMULA('Amount - ExpectedRevenue') != 0`

**Signature**

```apex
Formula notEqual(Decimal value)
Formula notEqual(Date value)
```

**Example**

```sql
SELECT Id
FROM Opportunity
WHERE FORMULA('Amount - ExpectedRevenue') != 0
```
```apex
SOQL.of(Opportunity.SObjectType)
    .whereAre(SOQL.Formula('Amount - ExpectedRevenue').notEqual(0))
    .toList();
```

### lessThan

- `WHERE FORMULA('OrderDate__c + DeliveryDays__c') < 2026-11-01`

**Signature**

```apex
Formula lessThan(Decimal value)
Formula lessThan(Date value)
```

**Example**

```sql
SELECT Id
FROM Order__c
WHERE FORMULA('OrderDate__c + DeliveryDays__c') < 2026-11-01
```
```apex
SOQL.of(Order__c.SObjectType)
    .whereAre(SOQL.Formula('OrderDate__c + DeliveryDays__c').lessThan(Date.newInstance(2026, 11, 1)))
    .toList();
```

### lessOrEqual

- `WHERE FORMULA('ShipDate__c - OrderDate__c') <= 2`

**Signature**

```apex
Formula lessOrEqual(Decimal value)
Formula lessOrEqual(Date value)
```

**Example**

```sql
SELECT Id
FROM Order__c
WHERE FORMULA('ShipDate__c - OrderDate__c') <= 2
```
```apex
SOQL.of(Order__c.SObjectType)
    .whereAre(SOQL.Formula('ShipDate__c - OrderDate__c').lessOrEqual(2))
    .toList();
```

### greaterThan

- `WHERE FORMULA('Revenue__c - Cost__c') > 250`

**Signature**

```apex
Formula greaterThan(Decimal value)
Formula greaterThan(Date value)
```

**Example**

```sql
SELECT Id
FROM Order__c
WHERE FORMULA('Revenue__c - Cost__c') > 250
```
```apex
SOQL.of(Order__c.SObjectType)
    .whereAre(SOQL.Formula('Revenue__c - Cost__c').greaterThan(250))
    .toList();
```

### greaterOrEqual

- `WHERE FORMULA('Amount + ExpectedRevenue') >= 1000.50`

**Signature**

```apex
Formula greaterOrEqual(Decimal value)
Formula greaterOrEqual(Date value)
```

**Example**

```sql
SELECT Id
FROM Opportunity
WHERE FORMULA('Amount + ExpectedRevenue') >= 1000.50
```
```apex
SOQL.of(Opportunity.SObjectType)
    .whereAre(SOQL.Formula('Amount + ExpectedRevenue').greaterOrEqual(1000.50))
    .toList();
```

## ADDITIONAL
### ignoreWhen

Condition will be removed when logic expression will evaluate to true.

**Signature**

```apex
Formula ignoreWhen(Boolean logicExpression)
```

**Example**

```sql
SELECT Id
FROM Opportunity
WHERE StageName = 'Closed Won'
```
```apex
Decimal minimumMargin = null;

SOQL.of(Opportunity.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Opportunity.StageName).equal('Closed Won'))
        .add(SOQL.Formula('Amount - ExpectedRevenue').greaterThan(minimumMargin)
            .ignoreWhen(minimumMargin == null)
        )
    )
    .toList();
```
