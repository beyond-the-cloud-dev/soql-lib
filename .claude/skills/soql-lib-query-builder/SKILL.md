---
name: soql-lib-query-builder
description: Apex query building with the SOQL Lib fluent API (SOQL.cls). Use when writing, changing or reviewing any SOQL query in Apex in a project that contains SOQL.cls, including replacing [SELECT ...] or Database.query, WHERE filters with SOQL.Filter / SOQL.FilterGroup, optional filters, date literals, semi-joins, aggregates, GROUP BY / HAVING, ORDER BY, LIMIT, subqueries, parent fields, picking toList / toObject / toMap / toIds / toValuesOf, or choosing user mode, system mode and sharing. Not for editing SOQL Lib's own source (SOQL.cls, SOQL_Test.cls).
---

# SOQL Lib: Query Builder

Every query is a chain on `SOQL.of(...)` or on a `SOQL_<Object>` selector, ending with a result method. SOQL Lib binds every filter value, so you never concatenate values or call `String.escapeSingleQuotes()`.

## Rules

1. Don't write `[SELECT ...]`, `Database.query()` or `Database.queryWithBinds()` in code that reads records.
2. If a `SOQL_<Object>` selector exists, start from it (`SOQL_Account.query()`). Otherwise start from `SOQL.of(Account.SObjectType)`. To create a selector, use the `soql-lib-selector` skill.
3. Pass fields as `SObjectField` tokens (`Account.Name`). Use String fields only for field lists that are built at runtime.
4. Build conditions with `SOQL.Filter` and `SOQL.FilterGroup`. Use `whereAre(String)` only for conditions that are built at runtime.
5. For an optional filter, add `.ignoreWhen(<value is empty>)` to the filter. Don't wrap the query in `if` branches.
6. Add `.asDateLiteral()` to filters that compare against date literals (`THIS_MONTH`, `LAST_N_DAYS:30`).
7. If a unit test will mock the query, give inline queries `.mockId('ClassName.methodName')` and return aggregates with `.toAggregatedProxy()`, not `.toAggregated()`. Tests then call `SOQL.mock('ClassName.methodName').thenReturn(...)`. For the tests themselves, use the `soql-lib-testing` skill.

```apex
List<Account> accounts = SOQL_Account.query()
    .with(Account.Industry)
    .with('Owner', User.Email)
    .whereAre(SOQL.Filter.with(Account.Industry).equal(industry).ignoreWhen(String.isBlank(industry)))
    .whereAre(SOQL.Filter.with(Account.CreatedDate).greaterThan('LAST_N_DAYS:30').asDateLiteral())
    .orderBy(Account.Name)
    .setLimit(100)
    .toList();
```

## SELECT

| Need | Call |
|---|---|
| Up to 5 fields | `.with(Account.Id, Account.Name, Account.Industry)` |
| 6+ fields | `.with(new List<SObjectField>{ Account.Id, Account.Name, ... })` |
| Parent fields (up to 5, or a list) | `.with('Owner', User.Name, User.Email)` |
| Child subquery | `.with(SOQL.SubQuery.of('Contacts').with(Contact.Id, Contact.Email).setLimit(5))` |
| Field set | `.withFieldSet('AccountListView')` |
| Runtime field list | `.with('Id, Name')` or `.with(List<String>)` |

Fields added later merge with the selector's default fields. Duplicates are ignored.

## WHERE

Field: `SOQL.Filter.id()`, `.recordType()` (DeveloperName), `.name()`, `.with(Account.Industry)`, `.with('Account', Account.Industry)` (parent field), `.with('Account.Owner.Email')`.

| Comparator | SOQL |
|---|---|
| `equal(v)` / `notEqual(v)` | `= :v` / `!= :v` |
| `lessThan` / `greaterThan` / `lessOrEqual` / `greaterOrEqual` | `<` `>` `<=` `>=` |
| `isNull()` / `isNotNull()` / `isTrue()` / `isFalse()` | `= null` / `!= null` / `= true` / `= false` |
| `contains('a')` / `startsWith('a')` / `endsWith('a')` | `LIKE '%a%'` / `'a%'` / `'%a'` |
| `notContains` / `notStartsWith` / `notEndsWith` | `NOT ... LIKE` |
| `contains('_', 'a', '%')` | `LIKE '_a%'`: custom wildcards |
| `containsSome(patterns)` | `LIKE :patterns`: matches any pattern. Patterns are used as given, so add `%` yourself |
| `isIn(collection)` / `notIn(collection)` | `IN :v` / `NOT IN :v` |
| `isIn(records, Contact.AccountId)` | `IN`: the values of that field taken from a record list |
| `isIn(SOQL.InnerJoin...)` / `notIn(SOQL.InnerJoin...)` | semi-join / anti-join |
| `includesAll` / `includesSome` / `excludesAll` / `excludesSome` | multi-select picklist `INCLUDES` / `EXCLUDES` |

Modifiers: `.ignoreWhen(Boolean)` drops the condition when the expression is true. `.asDateLiteral()` keeps a date literal unbound.

Combining conditions:

```apex
.whereAre(filterA).whereAre(filterB)               // A AND B (default)
.anyConditionMatching()                            // top-level conditions joined with OR
.conditionLogic('1 AND (2 OR 3)')                  // numbered in whereAre order
.whereAre(SOQL.FilterGroup                         // nested group
    .add(SOQL.Filter.with(Account.Industry).equal('IT'))
    .add(SOQL.Filter.with(Account.Type).equal('Partner'))
    .anyConditionMatching()
    .ignoreWhen(skipGroup))
```

Shortcuts: `.byId(id)`, `.byId(record)`, `.byIds(ids)`, `.byIds(records)`, `.byRecordType('Partner')`.

Semi-join:

```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(Contact.AccountId).isIn(
        SOQL.InnerJoin.of(Account.SObjectType)
            .with(Account.Id)
            .whereAre(SOQL.Filter.with(Account.Industry).equal('IT'))
    ))
    .toList();
```

## Aggregates, GROUP BY, HAVING

```apex
List<SOQL.AggregateResultProxy> totals = SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.StageName)                     // grouped fields appear only if added with with()
    .sum(Opportunity.Amount, 'total')
    .groupBy(Opportunity.StageName)
    .have(SOQL.HavingFilter.sum(Opportunity.Amount).greaterThan(10000))
    .mockId('OpportunityReport.totalsByStage')
    .toAggregatedProxy();

Decimal total = (Decimal) totals[0].get('total');
```

- Functions: `count()`, `count(field, alias)`, `countDistinct`, `sum`, `avg`, `min`, `max`, each also with `(relationshipName, field[, alias])`. `grouping(field, alias)` works with `groupByRollup` / `groupByCube`.
- When a query groups or aggregates, SOQL Lib drops every non-grouped field. This means selectors with default fields are safe for aggregate queries.
- `.toInteger()` adds `COUNT()` itself and clears the other fields: `SOQL_Account.query().byRecordType('Partner').toInteger()`.
- HAVING: `.have(SOQL.HavingFilter...)`, `.have(SOQL.HavingFilterGroup.add(...).add(...))`, `.anyHavingConditionMatching()`, `.havingConditionLogic('1 OR 2')`. HAVING values are bound too.
- To sort by an aggregate: `.orderByCount(Lead.Industry).sortDesc()`.

## ORDER BY, LIMIT, OFFSET

`.orderBy(Account.Name)` sorts ascending with nulls first. Chain `.sortDesc()` and `.nullsLast()` for a fixed direction. Use `.sort('DESC')` / `.nullsOrder('LAST')` / `.orderBy('Name', 'DESC')` only when the direction is decided at runtime. For a parent field: `.orderBy('Account', Account.Name)`. Then `.setLimit(n)` and `.offset(n)`.

## Result methods

| Need | Method | Returns |
|---|---|---|
| Records | `.toList()` | `List<SObject>` (assign to `List<Account>` directly) |
| One record | `(Account) .toObject()` | `null` for 0 rows; throws `QueryException` for 2+ rows |
| Exists? | `.doExist()` | `Boolean` |
| Count | `.toInteger()` | `Integer` |
| Id of the one record / all Ids | `.toId()` / `.toIds()` | `Id` / `Set<Id>` |
| Ids from a lookup | `.toIdsOf(Contact.AccountId)`, `.toIdsOf('Account', Account.OwnerId)` | `Set<Id>` |
| One field value | `(String) .toValueOf(Account.Industry)` | `Object` |
| Distinct values | `.toValuesOf(Account.Industry)`, `.toValuesOf('Owner', User.Email)` | `Set<String>` |
| Map by Id | `(Map<Id, Account>) .toMap()` | `Map<Id, SObject>` |
| Map by a field | `.toMap(Account.Name)`, `.toMap('Owner', User.Email)` | `Map<String, SObject>` |
| Key to value | `.toMap(Account.Name, Account.Industry)` | `Map<String, String>` |
| Map by an Id field | `.toIdMapBy(Contact.AccountId)` | `Map<Id, SObject>` |
| Grouped lists | `.toAggregatedMap(Account.Industry)`, `.toAggregatedIdMapBy(Contact.AccountId)` | `Map<String/Id, List<SObject>>` |
| Aggregates | `.toAggregatedProxy()` (mockable) / `.toAggregated()` | `List<SOQL.AggregateResultProxy>` / `List<AggregateResult>` |
| Batch / large data | `.toQueryLocator()`, `.toCursor()`, `.toPaginationCursor()` | `Database.QueryLocator` / `Cursor` / `PaginationCursor` |

- `toMap(field)`, `toIdMapBy`, `toAggregatedMap` and `toAggregatedIdMapBy` add the key field to SELECT and add `WHERE <key> != null`.
- `toIdsOf` and `toValuesOf` run a grouped query. They reject `Id` (use `toIds()`) and don't work on Custom Metadata Types.
- `toId`, `toIds`, `doExist`, `toValueOf` and `toInteger` clear the selected fields first, so the selector's default fields cost nothing.

## Security and sharing

| Calls | Access level | Sharing |
|---|---|---|
| none (default for `SOQL.of`) | `USER_MODE`: CRUD and FLS enforced | always enforced |
| `.systemMode()` | `SYSTEM_MODE` | inherited from the calling class |
| `.systemMode().withSharing()` | `SYSTEM_MODE` | `with sharing` |
| `.systemMode().withoutSharing()` | `SYSTEM_MODE` | `without sharing` |
| `.systemMode().withoutSharing().stripInaccessible()` | FLS applied by stripping fields | `without sharing` |

- User mode is the default. Don't call `.userMode()` on a query that never switched to system mode.
- Selectors usually set `.systemMode().withoutSharing()` in their constructor. Calling `.userMode()` on such a selector is the one case where it changes anything: it switches the query back to the running user's access.
- `.withSharing()` and `.withoutSharing()` take effect only after `.systemMode()`. In user mode, sharing is always enforced.
- In user mode, a field the user can't read makes the query throw. Use `.stripInaccessible()` to drop such fields instead.

## Debugging

`.preview()` logs the SOQL and its bind map at `ERROR` level. `.toString()` returns the SOQL with bind names (`WHERE Name = :v1`).

## Less common clauses

Read [references/advanced-clauses.md](references/advanced-clauses.md) for USING SCOPE, `FOR UPDATE` / `FOR VIEW` / `FOR REFERENCE` / `ALL ROWS`, WITH DATA CATEGORY, TYPEOF, DISTANCE, `toLabel` / `FORMAT` / field aliases, cursors and the `SOQL.Logger` hook for failed queries.

## Common mistakes

| Symptom | Fix |
|---|---|
| A selector method can't be called after `.with(...)` or `.byId(...)` | Inherited methods return `SOQL.Queryable`. Call the selector's own methods first. |
| `Variable does not exist: SObjectType` | A local variable shadows the type (`Contact contact`). Rename it to `contactRecord`. |
| `Method does not exist ... of(Schema.SObjectField)` on RecordType | Use `SOQL.of('RecordType')`. |
| `Variable does not exist: v1` from `toQueryLocator()` | The user lacks FLS on a selected field in user mode. Grant access or use `.systemMode()`. |
| Mocked test fails with `Use toAggregatedProxy()...` or a `NullPointerException` in `SOQL.SObjectMock.get` | Replace `.toAggregated()` with `.toAggregatedProxy()`. |
| Inline query built only for a single aggregate | Fine. You can also use the selector: grouping drops its default fields. |
| `.userMode()` on a `SOQL.of(...)` query | Remove it. User mode is the default. |
| `Field must be grouped or aggregated` | Group by every non-aggregated field you select, or don't select it. |
