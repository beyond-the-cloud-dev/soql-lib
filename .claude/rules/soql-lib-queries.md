---
paths:
  - "**/*.cls"
---

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
.whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
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

| Goal | Method | Notes |
|---|---|---|
| Multiple records | `.toList()` | |
| Single record | `.toObject()` | Returns `null` for 0 rows; throws for >1 row |
| Existence check | `.doExist()` | |
| COUNT | `.toInteger()` | |
| First record Id | `.toId()` | |
| All record Ids | `.toIds()` | |
| Ids from a field | `.toIdsOf(SObjectField)` | Field auto-added |
| Ids from parent field | `.toIdsOf(relationshipName, SObjectField)` | |
| Single field value | `.toValueOf(SObjectField)` | Returns `Object`, cast required |
| All values of one field | `.toValuesOf(SObjectField)` | Returns `Set<String>`; not for Custom Metadata |
| Map by record Id | `.toMap()` | `(Map<Id, T>)` cast required |
| Map by String field | `.toMap(SObjectField)` | Auto-adds `WHERE field != null` |
| Map by relationship field | `.toMap(relationshipName, SObjectField)` | Auto-adds null check |
| Map key → value | `.toMap(SObjectField, SObjectField)` | `Map<String, String>` |
| Map by Id field | `.toIdMapBy(SObjectField)` | Auto-adds null check |
| Map by related Id field | `.toIdMapBy(relationshipName, SObjectField)` | |
| Grouped by String key | `.toAggregatedMap(SObjectField)` | Auto-adds null check |
| Grouped by Id key | `.toAggregatedIdMapBy(SObjectField)` | Auto-adds null check |
| Aggregate (mockable) | `.toAggregatedProxy()` | Use instead of `.toAggregated()` when mocking |
| Aggregate | `.toAggregated()` | Cannot be mocked |
| Batch | `.toQueryLocator()` | |
| Large sets | `.toCursor()` / `.toPaginationCursor()` | |

## Security modes

- Selectors always set `.systemMode().withoutSharing()` in their constructor.
- Override to `.userMode()` only at call-site when FLS enforcement is required.
- Never call `.withSharing()` or `.withoutSharing()` without pairing with `.systemMode()`.
- Use `.stripInaccessible()` when you need field security without sharing rules.
