---
name: soql-lib-query-builder
description: >-
  Builds Salesforce SOQL queries using the SOQL Lib fluent builder API (SOQL.cls).
  Covers SELECT fields, WHERE filters, ORDER BY, LIMIT, aggregate functions, result
  methods (toList, toObject, toMap, toIds, toAggregated, etc.) and security modes.
  Use when writing any SOQL query with SOQL Lib, choosing a result method, or
  constructing WHERE conditions with SOQL.Filter / SOQL.FilterGroup.
---

# SOQL Lib — Query Builder

SOQL Lib is a fluent Apex builder for SOQL queries. Every method returns `Queryable`, enabling chaining. All filter values are automatically bound — never string-concatenated.

## When to Use

- Use this skill when writing a new SOQL query
- Use this skill when choosing the right result method (`toList`, `toObject`, `toMap`, etc.)
- Use this skill when building WHERE conditions with `SOQL.Filter` or `SOQL.FilterGroup`
- Use this skill when working with aggregate queries, sub-queries, or parent field traversal

## Instructions

### Entry point

Always use `SOQL.of(SObjectType)` when no selector exists. Prefer `SObjectType` over `String` for compile-time safety:

```apex
// If a selector exists — prefer it
SOQL_Account.query().with(Account.Id, Account.Name).toList();

// No selector — use inline
SOQL.of(Account.SObjectType).with(Account.Id, Account.Name).toList();
SOQL.of('Account').toList(); // dynamic only
```

### SELECT fields

```apex
.with(Account.Id, Account.Name, Account.Industry)               // up to 5 fields
.with(new List<SObjectField>{ Account.Id, Account.Name, ... })  // 6+ fields
.with('CreatedBy', User.Name)                                   // parent field
.with('CreatedBy', User.Id, User.Name, User.Email)              // multiple parent fields
.with(SOQL.SubQuery.of('Contacts').with(Contact.Id, Contact.Name)) // child sub-query
.withFieldSet('AccountFieldSet')                                // Field Set
.with('Id, Name, Industry')                                     // dynamic String — avoid when possible
```

### WHERE — single condition

```apex
.whereAre(SOQL.Filter.id().equal(recordId))
.whereAre(SOQL.Filter.recordType().equal('Partner'))
.whereAre(SOQL.Filter.name().contains('Acme'))
.whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
.whereAre(SOQL.Filter.with('CreatedBy', User.Email).equal('admin@example.com'))
```

### WHERE — compound conditions

```apex
// AND (default)
.whereAre(SOQL.FilterGroup
    .add(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
)

// OR
.whereAre(SOQL.FilterGroup
    .add(SOQL.Filter.with(Account.Id).equal(id))
    .add(SOQL.Filter.with(Account.Name).contains('Test'))
    .anyConditionMatching()
)

// Custom logic — e.g. 1 AND (2 OR 3)
.whereAre(SOQL.Filter.with(Account.Name).equal('A'))
.whereAre(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
.whereAre(SOQL.Filter.with(Account.Industry).equal('Tech'))
.conditionLogic('1 AND (2 OR 3)')

// Top-level OR connector
.anyConditionMatching()
```

### WHERE — filter comparators

| Method | SQL equivalent |
|---|---|
| `.equal(val)` | `= :v` |
| `.notEqual(val)` | `!= :v` |
| `.isNull()` / `.isNotNull()` | `= null` / `!= null` |
| `.isTrue()` / `.isFalse()` | `= true` / `= false` |
| `.lessThan(val)` / `.greaterThan(val)` | `< :v` / `> :v` |
| `.lessOrEqual(val)` / `.greaterOrEqual(val)` | `<= :v` / `>= :v` |
| `.contains('txt')` | `LIKE '%txt%'` |
| `.startsWith('txt')` | `LIKE 'txt%'` |
| `.endsWith('txt')` | `LIKE '%txt'` |
| `.notContains('txt')` | `(NOT ... LIKE '%txt%')` |
| `.isIn(new List<Object>{...})` | `IN (:v)` |
| `.notIn(new List<Object>{...})` | `NOT IN (:v)` |
| `.isIn(SOQL.InnerJoin...)` | `IN (SELECT ...)` |
| `.isIn(records, Account.OwnerId)` | `IN` from SObject list |
| `.includesAll(vals)` / `.includesSome(vals)` | `INCLUDES` (multi-picklist) |
| `.asDateLiteral()` | unbound — for `THIS_MONTH`, `LAST_N_DAYS:30`, etc. |

### WHERE — modifiers

```apex
// Skip condition when expression is true
.whereAre(SOQL.Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null))

// Skip entire group
SOQL.FilterGroup.add(...).ignoreWhen(filters.isEmpty())

// Date literals (cannot be bound)
.whereAre(SOQL.Filter.with(Opportunity.CloseDate).equal('THIS_MONTH').asDateLiteral())
.whereAre(SOQL.Filter.with(Account.CreatedDate).greaterThan('LAST_N_DAYS:30').asDateLiteral())
```

### WHERE — predefined shortcuts

```apex
.byId(recordId)                       // WHERE Id = :id
.byId(record)                         // WHERE Id = :record.Id
.byIds(new Set<Id>{ id1, id2 })       // WHERE Id IN (...)
.byIds(records)                       // WHERE Id IN (ids from list)
.byRecordType('Partner')              // WHERE RecordType.DeveloperName = 'Partner'
```

### Semi-join (InnerJoin)

```apex
.whereAre(SOQL.Filter.with(Contact.AccountId).isIn(
    SOQL.InnerJoin.of(Account.SObjectType)
        .with(Account.Id)
        .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
))
```

### ORDER BY / LIMIT / OFFSET

```apex
.orderBy(Account.Name)                // ASC NULLS FIRST (default)
.orderBy(Account.Name).sortDesc()     // DESC
.orderBy(Account.Name).nullsLast()    // NULLS LAST
.orderBy('Account', Account.Name)     // parent field
.orderBy('Name', 'DESC')             // dynamic direction
.setLimit(100)
.offset(20)
```

### Aggregate functions

```apex
.count()                              // SELECT COUNT() — use with toInteger()
.count(Opportunity.Id, 'cnt')        // COUNT(Id) cnt
.avg(Opportunity.Amount, 'avgAmt')   // AVG(Amount) avgAmt
.sum(Opportunity.Amount, 'total')    // SUM(Amount) total
.min(Contact.CreatedDate)            // MIN(CreatedDate)
.max(Campaign.BudgetedCost)          // MAX(BudgetedCost)
.countDistinct(Lead.Company)         // COUNT_DISTINCT(Company)
.grouping(Lead.LeadSource, 'grpLS') // GROUPING — for ROLLUP/CUBE
```

### GROUP BY / HAVING

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name, 'cnt')
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
    .toAggregated();

.groupByRollup(Lead.LeadSource)       // GROUP BY ROLLUP(...)
.groupByCube(Account.Type)            // GROUP BY CUBE(...)
```

### Security modes

```apex
.userMode()         // FLS + sharing enforced (default for inline queries)
.systemMode()       // ignores FLS; sharing controlled by class keyword
.withSharing()      // explicit with sharing (pair with systemMode)
.withoutSharing()   // explicit without sharing (pair with systemMode)
.stripInaccessible() // strip inaccessible fields (pair with systemMode + withoutSharing)
```

Selectors default to `.systemMode().withoutSharing()`. Override ad-hoc: `.userMode()`.

### Result methods

| Goal | Method |
|---|---|
| Multiple records | `.toList()` |
| Single record (null-safe — returns `null` for 0 rows) | `.toObject()` |
| Record existence | `.doExist()` |
| All record Ids | `.toIds()` |
| First record Id | `.toId()` |
| Ids from a field | `.toIdsOf(Account.OwnerId)` |
| Single field value | `.toValueOf(Account.Name)` |
| All values of one field | `.toValuesOf(Account.Name)` |
| Map keyed by record Id | `.toMap()` |
| Map keyed by Id field | `.toIdMapBy(Account.OwnerId)` |
| Map keyed by String field | `.toMap(Account.Name)` |
| Map key → value | `.toMap(Account.Name, Account.Industry)` |
| Grouped by String key | `.toAggregatedMap(Account.Industry)` |
| Grouped by Id field | `.toAggregatedIdMapBy(Account.OwnerId)` |
| COUNT | `.toInteger()` |
| Aggregate | `.toAggregated()` |
| Aggregate (mockable) | `.toAggregatedProxy()` |
| Batch | `.toQueryLocator()` |
| Large sets | `.toCursor()` / `.toPaginationCursor()` |
| Debug SOQL string | `.toString()` |

> `toMap` / `toIdMapBy` / `toAggregatedMap` automatically add `WHERE <keyField> != null`.

### Debug

```apex
SOQL.of(Account.SObjectType).preview().toList(); // logs SOQL + bind vars at ERROR level
```

## Examples

```apex
// List with filters
List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name, Account.Industry)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .orderBy(Account.Name)
    .setLimit(50)
    .toList();

// Single record (null-safe)
Account acc = (Account) SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .byId(accountId)
    .toObject();

// Parent fields
List<Contact> contacts = SOQL.of(Contact.SObjectType)
    .with(Contact.Id, Contact.LastName)
    .with('Account', Account.Name, Account.Industry)
    .toList();

// Child sub-query
List<Account> accs = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Id, Contact.LastName)
        .orderBy(Contact.LastName)
    ).toList();

// Dynamic / optional filter
List<Account> result = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null))
    .toList();

// Aggregate with GROUP BY + HAVING
List<AggregateResult> results = SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.StageName)
    .sum(Opportunity.Amount, 'total')
    .count(Opportunity.Id, 'cnt')
    .groupBy(Opportunity.StageName)
    .have(SOQL.HavingFilter.sum(Opportunity.Amount).greaterThan(10000))
    .toAggregated();

// Map keyed by Id
Map<Id, Account> byId = (Map<Id, Account>) SOQL.of(Account.SObjectType).toMap();

// Map grouped by field
Map<String, List<Account>> byIndustry =
    (Map<String, List<Account>>) SOQL.of(Account.SObjectType).toAggregatedMap(Account.Industry);

// Batch QueryLocator
Database.QueryLocator ql = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .toQueryLocator();
```
