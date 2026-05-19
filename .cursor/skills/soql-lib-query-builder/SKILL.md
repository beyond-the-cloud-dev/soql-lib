---
name: soql-lib-query-builder
description: >-
  Builds Salesforce SOQL queries using the SOQL Lib fluent builder API (SOQL.cls).
  Covers SELECT fields, toLabel, format, WHERE filters, USING SCOPE, FOR clauses,
  WITH DATA CATEGORY, ORDER BY, LIMIT, OFFSET, aggregate functions, GROUP BY / HAVING,
  all result methods (toList, toObject, toMap, toIds, toAggregated, toCursor, etc.)
  and security modes. Use when writing any SOQL query with SOQL Lib.
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
.with(Account.Id)                                               // single field, can be chained
.with(new List<SObjectField>{ Account.Id, Account.Name, ... })  // 6+ fields
.with('CreatedBy', User.Name)                                   // parent field (up to 5)
.with('CreatedBy', User.Id, User.Name, User.Email)              // multiple parent fields
.with('CreatedBy', new List<SObjectField>{ User.Id, User.Name, User.Phone, User.FirstName, User.LastName, User.Email }) // 6+ parent fields
.with(SOQL.SubQuery.of('Contacts').with(Contact.Id, Contact.Name)) // child sub-query
.withFieldSet('AccountFieldSet')                                // Field Set
.with('Id, Name, Industry')                                     // dynamic String — avoid when possible
```

### toLabel — translate field value to user language

```apex
.toLabel(Lead.Status)                         // SELECT toLabel(Status)
.toLabel(Lead.Status, 'leadStatus')           // SELECT toLabel(Status) leadStatus
.toLabel('Recordtype.Name')                   // SELECT toLabel(Recordtype.Name)
.toLabel('Recordtype.Name', 'recordTypeName') // SELECT toLabel(Recordtype.Name) recordTypeName
```

### format — apply locale formatting to a field

```apex
.format(Opportunity.Amount)           // SELECT FORMAT(Amount)
.format(Opportunity.Amount, 'amt')    // SELECT FORMAT(Amount) amt
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
.byIds(new List<Id>{ id1, id2 })      // WHERE Id IN (...)
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

### USING SCOPE

Scope the query to a subset of records based on the running user's context:

```apex
.mineScope()                // USING SCOPE MINE — records owned by current user
.delegatedScope()           // USING SCOPE DELEGATED — delegated records
.mineAndMyGroupsScope()     // USING SCOPE MINE_AND_MY_GROUPS — ProcessInstanceWorkItem only
.myTerritoryScope()         // USING SCOPE MY_TERRITORY — requires territory management
.myTeamTerritoryScope()     // USING SCOPE MY_TEAM_TERRITORY — requires territory management
.teamScope()                // USING SCOPE TEAM — account team records
```

### FOR clauses

```apex
.forReference()   // FOR REFERENCE — notify when record is referenced from custom UI
.forView()        // FOR VIEW — update LastViewedDate
.forUpdate()      // FOR UPDATE — lock records during update
.allRows()        // ALL ROWS — include deleted records and archived activities
```

### WITH DATA CATEGORY

For Knowledge articles and objects with data categories:

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(SOQL.DataCategoryFilter.with('Geography__c').at(new List<String>{ 'Europe__c', 'North_America__c' }))
    .toList();
```

### ORDER BY / LIMIT / OFFSET

```apex
.orderBy(Account.Name)                    // ASC NULLS FIRST (default)
.orderBy(Account.Name).sortDesc()         // DESC
.orderBy(Account.Name).nullsLast()        // NULLS LAST
.orderBy('Account', Account.Name)         // parent field
.orderBy('Name', 'DESC')                  // dynamic direction — use only for dynamic
.sort('DESC')                             // dynamic direction on last orderBy
.nullsOrder('LAST')                       // dynamic nulls order
.orderByCount(Account.Industry).sortDesc().nullsLast() // ORDER BY COUNT(field)
.setLimit(100)
.offset(20)
```

### Aggregate functions

```apex
.count()                                    // SELECT COUNT() — use with toInteger()
.count(Opportunity.Id, 'cnt')              // COUNT(Id) cnt
.count('Account', Account.Name, 'names')   // COUNT(Account.Name) names
.avg(Opportunity.Amount, 'avgAmt')         // AVG(Amount) avgAmt
.avg('Opportunity', Opportunity.Amount)     // AVG(Opportunity.Amount)
.sum(Opportunity.Amount, 'total')          // SUM(Amount) total
.sum('Opportunity', Opportunity.Amount)     // SUM(Opportunity.Amount)
.min(Contact.CreatedDate)                  // MIN(CreatedDate)
.min('Account', Account.CreatedDate, 'createdDate') // MIN(Account.CreatedDate) createdDate
.max(Campaign.BudgetedCost)               // MAX(BudgetedCost)
.max('Campaign', Campaign.BudgetedCost)   // MAX(Campaign.BudgetedCost)
.countDistinct(Lead.Company)              // COUNT_DISTINCT(Company)
.countDistinct('Lead', Lead.Company, 'company') // COUNT_DISTINCT(Lead.Company) company
.grouping(Lead.LeadSource, 'grpLS')       // GROUPING — for ROLLUP/CUBE
```

> **Note:** `COUNT()` must be the only element in the SELECT list — other fields are removed automatically. Other aggregate functions auto-remove non-grouped default fields to avoid `Field must be grouped or aggregated`.

### GROUP BY / HAVING

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name, 'cnt')
    .groupBy(Lead.LeadSource)
    .have(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
    .toAggregated();

// Multiple GROUP BY
.groupBy(Contact.FirstName)
.groupBy(Contact.LastName)

// Related field GROUP BY
.groupBy('OpportunityLineItem.Opportunity.Account', Account.Id)

// ROLLUP / CUBE
.groupByRollup(Lead.LeadSource)           // GROUP BY ROLLUP(...)
.groupByRollup('ConvertedOpportunity', Opportunity.StageName)
.groupByCube(Account.Type)               // GROUP BY CUBE(...)
.groupByCube('ConvertedOpportunity', Opportunity.StageName)

// HAVING logic
.have(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
.have(SOQL.HavingFilter.with(Lead.City).startsWith('San'))
.anyHavingConditionMatching()            // default AND → OR between HAVING conditions
.havingConditionLogic('1 OR 2')          // custom HAVING logic
.have('COUNT(Name) > 100 AND COUNT(Name) < 200') // dynamic HAVING string
```

### Security modes

```apex
.userMode()         // FLS + sharing enforced (default for inline queries)
.systemMode()       // ignores FLS; sharing controlled by class keyword
.withSharing()      // explicit with sharing (requires systemMode)
.withoutSharing()   // explicit without sharing (requires systemMode)
.stripInaccessible() // strip inaccessible fields (use with systemMode + withoutSharing)
.stripInaccessible(AccessType.READABLE) // with specific AccessType
```

Selectors default to `.systemMode().withoutSharing()`. Override ad-hoc: `.userMode()`.

### Result methods

| Goal | Method | Return type |
|---|---|---|
| Multiple records | `.toList()` | `List<SObject>` |
| Single record (null-safe — returns `null` for 0 rows) | `.toObject()` | `SObject` |
| Record existence | `.doExist()` | `Boolean` |
| First record Id | `.toId()` | `Id` |
| All record Ids | `.toIds()` | `Set<Id>` |
| Ids from a field | `.toIdsOf(Account.OwnerId)` | `Set<Id>` |
| Ids from a parent field | `.toIdsOf('Parent', Account.Id)` | `Set<Id>` |
| Single field value | `.toValueOf(Account.Name)` | `Object` (cast required) |
| All values of one field | `.toValuesOf(Account.Name)` | `Set<String>` (not for Custom Metadata) |
| All values of parent field | `.toValuesOf('Parent', Account.Name)` | `Set<String>` |
| Map keyed by record Id | `.toMap()` | `Map<Id, SObject>` |
| Map keyed by String field | `.toMap(Account.Name)` | `Map<String, SObject>` |
| Map keyed by relationship field | `.toMap('Parent.CreatedBy', User.Email)` | `Map<String, SObject>` |
| Map key → String value | `.toMap(Account.Name, Account.Industry)` | `Map<String, String>` |
| Map keyed by Id field | `.toIdMapBy(Account.OwnerId)` | `Map<Id, SObject>` |
| Map keyed by related Id field | `.toIdMapBy('Parent', Account.Id)` | `Map<Id, SObject>` |
| Grouped by String key | `.toAggregatedMap(Account.Industry)` | `Map<String, List<SObject>>` |
| Grouped by String key + value list | `.toAggregatedMap(Account.Industry, Account.Name)` | `Map<String, List<String>>` |
| Grouped by relationship key | `.toAggregatedMap('Parent.CreatedBy', User.Email)` | `Map<String, List<SObject>>` |
| Grouped by Id key | `.toAggregatedIdMapBy(Account.OwnerId)` | `Map<Id, List<SObject>>` |
| Grouped by related Id key | `.toAggregatedIdMapBy('Parent', Account.Id)` | `Map<Id, List<SObject>>` |
| COUNT | `.toInteger()` | `Integer` |
| Aggregate | `.toAggregated()` | `List<AggregateResult>` |
| Aggregate (mockable) | `.toAggregatedProxy()` | `List<SOQL.AggregateResultProxy>` |
| Batch | `.toQueryLocator()` | `Database.QueryLocator` |
| Large sets (streaming) | `.toCursor()` | `Database.Cursor` |
| Large sets (pagination) | `.toPaginationCursor()` | `Database.PaginationCursor` |
| Debug SOQL string | `.toString()` | `String` |

> **Important behaviors:**
> - `toObject()`: throws when >1 row, returns `null` (no exception) for 0 rows.
> - `toMap()`, `toIdMapBy()`, `toAggregatedMap()`, `toAggregatedIdMapBy()` automatically add `WHERE <keyField> != null`.
> - `toValuesOf()` does not work with Custom Metadata.
> - Map result types require explicit casting: `(Map<Id, Account>)`.

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

// ROLLUP with GROUPING
List<AggregateResult> rollup = SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource, Lead.Rating)
    .grouping(Lead.LeadSource, 'grpLS')
    .grouping(Lead.Rating, 'grpRating')
    .count(Lead.Name, 'cnt')
    .groupByRollup(Lead.LeadSource)
    .groupByRollup(Lead.Rating)
    .toAggregated();

// Map keyed by Id
Map<Id, Account> byId = (Map<Id, Account>) SOQL.of(Account.SObjectType).toMap();

// Map grouped by field
Map<String, List<Account>> byIndustry =
    (Map<String, List<Account>>) SOQL.of(Account.SObjectType).toAggregatedMap(Account.Industry);

// Map keyed by owner Id
Map<Id, List<Account>> byOwner =
    (Map<Id, List<Account>>) SOQL.of(Account.SObjectType).toAggregatedIdMapBy(Account.OwnerId);

// Extract single field value
String adminProfileId = (String) SOQL.of(Profile.SObjectType)
    .whereAre(SOQL.Filter.name().equal('System Administrator'))
    .toValueOf(Profile.Name);

// Extract set of field values
Set<Id> ownerIds = SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .toIdsOf(Account.OwnerId);

// Extract set of string values
Set<String> industries = SOQL.of(Account.SObjectType).toValuesOf(Account.Industry);

// toLabel — translated field
List<Lead> leads = SOQL.of(Lead.SObjectType)
    .with(Lead.Company)
    .toLabel(Lead.Status)
    .toList();

// USING SCOPE — current user's records only
List<Task> myTasks = SOQL.of(Task.SObjectType)
    .with(Task.Subject, Task.Status)
    .mineScope()
    .toList();

// FOR UPDATE — lock records
List<Contact> locked = SOQL.of(Contact.SObjectType)
    .byIds(contactIds)
    .forUpdate()
    .toList();

// ALL ROWS — include deleted
Integer total = SOQL.of(Contact.SObjectType).count().allRows().toInteger();

// Batch QueryLocator
Database.QueryLocator ql = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .toQueryLocator();

// Cursor for large sets
Database.Cursor cursor = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .toCursor();

// Pagination cursor
Database.PaginationCursor pCursor = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .orderBy(Account.Name)
    .setLimit(100)
    .toPaginationCursor();
```
