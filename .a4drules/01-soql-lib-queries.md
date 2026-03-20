# SOQL Lib — Query Rules

## Never write raw SOQL

Never use inline SOQL brackets or `Database.query()`. Always use SOQL Lib.

```apex
// WRONG
List<Account> accounts = [SELECT Id, Name FROM Account WHERE Industry = :industry];

// CORRECT
List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Industry).equal(industry))
    .toList();
```

## Always prefer a selector over inline SOQL.of()

If a `SOQL_<ObjectName>` selector exists, use it. Create one if it is missing.

```apex
// CORRECT
SOQL_Account.query().byType('Customer').toList();
```

## Always use SObjectField tokens, never String field names

```apex
// WRONG
.with('Id, Name, Industry')

// CORRECT
.with(Account.Id, Account.Name, Account.Industry)
// 6+ fields: .with(new List<SObjectField>{ Account.Id, Account.Name, ... })
```

Only use `String` fields for truly dynamic field lists. Use `.toLabel()` for translated fields, `.format()` for locale-formatted fields.

## Always use SOQL.Filter for WHERE conditions

```apex
.whereAre(SOQL.Filter.id().equal(recordId))
.whereAre(SOQL.Filter.recordType().equal('Partner'))
.whereAre(SOQL.Filter.name().contains('Acme'))
.whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
.whereAre(SOQL.Filter.with('CreatedBy', User.Email).equal('admin@example.com'))
```

## Predefined WHERE shortcuts

```apex
.byId(recordId)                       // WHERE Id = :id
.byId(record)                         // WHERE Id = :record.Id
.byIds(new Set<Id>{ id1, id2 })       // WHERE Id IN (...)
.byIds(records)                       // WHERE Id IN (ids from list)
.byRecordType('Partner')              // WHERE RecordType.DeveloperName = 'Partner'
```

## Always use .ignoreWhen() for optional filters

```apex
// CORRECT
.whereAre(SOQL.Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null))
```

## Always use .asDateLiteral() for date literal strings

```apex
.whereAre(SOQL.Filter.with(Opportunity.CloseDate).equal('THIS_MONTH').asDateLiteral())
.whereAre(SOQL.Filter.with(Account.CreatedDate).greaterThan('LAST_N_DAYS:30').asDateLiteral())
```

## Semi-join (InnerJoin)

```apex
.whereAre(SOQL.Filter.with(Contact.AccountId).isIn(
    SOQL.InnerJoin.of(Account.SObjectType)
        .with(Account.Id)
        .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
))
```

## Aggregate functions

```apex
.count()                               // SELECT COUNT() — use with .toInteger()
.count(Opportunity.Id, 'cnt')         // COUNT(Id) cnt
.avg(Opportunity.Amount, 'avgAmt')    // AVG(Amount) avgAmt
.sum(Opportunity.Amount, 'total')     // SUM(Amount) total
.min(Contact.CreatedDate)             // MIN(CreatedDate)
.max(Campaign.BudgetedCost)           // MAX(BudgetedCost)
.countDistinct(Lead.Company)          // COUNT_DISTINCT(Company)
.grouping(Lead.LeadSource, 'grpLS')   // GROUPING — for ROLLUP/CUBE
```

> `COUNT()` must be the only SELECT element. Other aggregate functions auto-remove non-grouped default fields to avoid `Field must be grouped or aggregated`.

## GROUP BY / HAVING

```apex
.groupBy(Lead.LeadSource)
.groupByRollup(Lead.LeadSource)              // GROUP BY ROLLUP(...)
.groupByCube(Account.Type)                   // GROUP BY CUBE(...)

.have(SOQL.HavingFilter.count(Lead.Name).greaterThan(100))
.have(SOQL.HavingFilter.sum(Opportunity.Amount).greaterThan(10000))
.anyHavingConditionMatching()               // AND → OR between HAVING conditions
.havingConditionLogic('1 OR 2')             // custom HAVING logic
```

## WITH DATA CATEGORY

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(SOQL.DataCategoryFilter.with('Geography__c').at(new List<String>{ 'Europe__c' }))
    .toList();
```

## USING SCOPE — use when filtering by user context

```apex
.mineScope()             // USING SCOPE MINE — records owned by running user
.delegatedScope()        // USING SCOPE DELEGATED
.mineAndMyGroupsScope()  // USING SCOPE MINE_AND_MY_GROUPS (ProcessInstanceWorkItem)
.myTerritoryScope()      // USING SCOPE MY_TERRITORY
.myTeamTerritoryScope()  // USING SCOPE MY_TEAM_TERRITORY
.teamScope()             // USING SCOPE TEAM
```

## FOR clauses

```apex
.forReference()   // FOR REFERENCE — notify when referenced from custom UI
.forView()        // FOR VIEW — update LastViewedDate
.forUpdate()      // FOR UPDATE — lock records during DML
.allRows()        // ALL ROWS — include deleted and archived records
```

## ORDER BY — use .sortDesc() and .nullsLast() for static ordering

```apex
.orderBy(Account.Name).sortDesc()           // DESC
.orderBy(Account.Name).nullsLast()          // NULLS LAST
.orderBy('Account', Account.Name)           // parent field
.orderBy('Name', 'DESC')                    // dynamic direction — use only when dynamic
.orderByCount(Account.Industry).sortDesc()  // ORDER BY COUNT(field) — for grouped queries
```

## Choose the correct result method

| Goal | Method | Return type | Notes |
|---|---|---|---|
| Multiple records | `.toList()` | `List<SObject>` | |
| Single record | `.toObject()` | `SObject` | Returns `null` for 0 rows; throws for >1 row |
| Existence check | `.doExist()` | `Boolean` | |
| COUNT | `.toInteger()` | `Integer` | |
| First record Id | `.toId()` | `Id` | |
| All record Ids | `.toIds()` | `Set<Id>` | |
| Ids from a field | `.toIdsOf(SObjectField)` | `Set<Id>` | Field auto-added |
| Ids from parent field | `.toIdsOf(relationshipName, SObjectField)` | `Set<Id>` | |
| Single field value | `.toValueOf(SObjectField)` | `Object` | Cast required |
| All values of one field | `.toValuesOf(SObjectField)` | `Set<String>` | Not for Custom Metadata |
| Map by record Id | `.toMap()` | `Map<Id, SObject>` | Cast required |
| Map by String field | `.toMap(SObjectField)` | `Map<String, SObject>` | Auto-adds `WHERE field != null` |
| Map by relationship field | `.toMap(relationshipName, SObjectField)` | `Map<String, SObject>` | Auto-adds null check |
| Map key → value | `.toMap(SObjectField, SObjectField)` | `Map<String, String>` | |
| Map by Id field | `.toIdMapBy(SObjectField)` | `Map<Id, SObject>` | Auto-adds null check |
| Map by related Id field | `.toIdMapBy(relationshipName, SObjectField)` | `Map<Id, SObject>` | |
| Grouped by String key | `.toAggregatedMap(SObjectField)` | `Map<String, List<SObject>>` | Auto-adds null check |
| Grouped by Id key | `.toAggregatedIdMapBy(SObjectField)` | `Map<Id, List<SObject>>` | Auto-adds null check |
| Aggregate (mockable) | `.toAggregatedProxy()` | `List<SOQL.AggregateResultProxy>` | Use instead of `.toAggregated()` when mocking |
| Aggregate | `.toAggregated()` | `List<AggregateResult>` | Cannot be mocked |
| Batch | `.toQueryLocator()` | `Database.QueryLocator` | |
| Large sets | `.toCursor()` / `.toPaginationCursor()` | `Database.Cursor` | |

## Debug

```apex
SOQL.of(Account.SObjectType).preview().toList(); // logs SOQL + bind vars at ERROR level
```

## Security modes

- Selectors always set `.systemMode().withoutSharing()` in their constructor.
- Override to `.userMode()` only at call-site when FLS enforcement is required.
- Never call `.withSharing()` or `.withoutSharing()` without pairing with `.systemMode()`.
- Use `.stripInaccessible()` when you need field security without sharing rules.
