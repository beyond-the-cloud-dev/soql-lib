---
name: soql-lib-query-builder
description: Apex query building with the SOQL Lib fluent API (SOQL.cls). Use when writing, changing or reviewing any SOQL query in Apex in a project that contains SOQL.cls, including replacing [SELECT ...] or Database.query, WHERE filters with SOQL.Filter / SOQL.FilterGroup, optional filters, date literals, semi-joins, aggregates, GROUP BY / HAVING, ORDER BY, LIMIT, subqueries, parent fields, picking a result method (toList, toObject, toIds, toIdsOf, toValuesOf, toMap, toIdMapBy, toAggregatedMap) instead of a for loop that builds a Set or Map from query results, or choosing user mode, system mode and sharing. Not for editing SOQL Lib's own source (SOQL.cls, SOQL_Test.cls).
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
8. Before you write a `for` loop over `toList()` to build a `Set`, a `Map` or grouped lists, use the result method that returns that shape (see [Result methods](#result-methods)). Loop only when you need a shape no result method returns.

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

Use a result method before you write a loop. These methods add the key field to the query, skip records whose key is null, and return a typed collection.

```apex
// Don't: query, then loop
Set<Id> accountIds = new Set<Id>();
for (Contact contactRecord : SOQL_Contact.query().byIds(contactIds).toList()) {
    accountIds.add(contactRecord.AccountId);
}

// Do
Set<Id> accountIds = SOQL_Contact.query().byIds(contactIds).toIdsOf(Contact.AccountId);
```

| Loop you would write | Result method |
|---|---|
| `Set<Id>` of record Ids | `.toIds()` |
| `Set<Id>` of a lookup field | `.toIdsOf(Contact.AccountId)`, or `.toIdsOf('Account', Account.OwnerId)` for a parent's field |
| `Set<String>` of a field's distinct values | `.toValuesOf(Account.Industry)`, `.toValuesOf('Owner', User.Email)` |
| `Map<Id, SObject>` by record Id | `(Map<Id, Account>) .toMap()` |
| `Map<Id, SObject>` by a lookup field | `(Map<Id, Contact>) .toIdMapBy(Contact.AccountId)`, `.toIdMapBy('Account', Account.OwnerId)` |
| `Map<String, SObject>` by a field | `(Map<String, Account>) .toMap(Account.Name)`, `.toMap('Owner', User.Email)` |
| `Map<String, String>` from a field to another field | `.toMap(Account.Name, Account.Industry)`, `.toMap(Contact.Email, 'Account', Account.Name)` |
| `Map<Id, List<SObject>>` grouped by a lookup | `(Map<Id, List<Contact>>) .toAggregatedIdMapBy(Contact.AccountId)`, `.toAggregatedIdMapBy('Account', Account.OwnerId)` |
| `Map<String, List<SObject>>` grouped by a field | `(Map<String, List<Account>>) .toAggregatedMap(Account.Industry)`, `.toAggregatedMap('Owner', User.Email)` |
| `Map<String, List<String>>` of values grouped by a field | `.toAggregatedMap(Account.Industry, Account.Name)`, `.toAggregatedMap(Contact.Title, 'Account', Account.Name)` |
| Check whether any row exists | `.doExist()` |
| Read one field of one record | `(String) .toValueOf(Account.Industry)` |
| Count rows | `.toInteger()` |

All result methods:

```apex
// RECORDS
SObject toObject();                    // null for 0 rows; QueryException for 2+ rows
List<SObject> toList();
Integer toInteger();                   // adds COUNT() if no aggregate function is selected
Boolean doExist();                     // clears the fields, adds LIMIT 1
Database.QueryLocator toQueryLocator();
Database.Cursor toCursor();
Database.PaginationCursor toPaginationCursor();
// AGGREGATE RESULTS
List<AggregateResult> toAggregated();
List<SOQL.AggregateResultProxy> toAggregatedProxy(); // use when you need mocking
// STRING
String toString();                     // SOQL with bind names; doesn't run the query
// IDS
Id toId();                             // clears the fields; null for 0 rows, QueryException for 2+ (add .setLimit(1))
Set<Id> toIds();                       // clears the fields
Set<Id> toIdsOf(SObjectField field);
Set<Id> toIdsOf(String relationshipName, SObjectField targetKeyField);
// VALUE
Object toValueOf(SObjectField fieldToExtract);  // selects only this field; null for 0 rows, QueryException for 2+
Set<String> toValuesOf(SObjectField fieldToExtract);
Set<String> toValuesOf(String relationshipName, SObjectField targetKeyField);
// ID MAP
Map<Id, SObject> toMap();
Map<Id, SObject> toIdMapBy(SObjectField field);
Map<Id, SObject> toIdMapBy(String relationshipName, SObjectField targetKeyField);
Map<Id, List<SObject>> toAggregatedIdMapBy(SObjectField keyField);
Map<Id, List<SObject>> toAggregatedIdMapBy(String relationshipName, SObjectField targetKeyField);
// VALUE MAP
Map<String, SObject> toMap(SObjectField keyField);
Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField);
Map<String, String> toMap(SObjectField keyField, SObjectField valueField);
Map<String, String> toMap(SObjectField keyField, String relationshipName, SObjectField targetKeyField);
Map<String, List<SObject>> toAggregatedMap(SObjectField keyField);
Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField);
Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField);
Map<String, List<String>> toAggregatedMap(SObjectField keyField, String relationshipName, SObjectField targetKeyField);
```

How they behave:

- `toList()` can be assigned to `List<Account>` without a cast. Maps of records are created with the real SObject type, so cast them: `(Map<Id, Account>)`, `(Map<String, List<Account>>)`. `Set` results and the `String`-valued maps need no cast.
- `toIdsOf` and `toValuesOf` run a grouped query (`GROUP BY` the field, `WHERE field != null`), which returns one row per distinct value instead of one per record. They reject `Id` (use `toIds()`), and they don't work on Custom Metadata Types.
- `toIdMapBy`, `toAggregatedIdMapBy`, `toMap(keyField...)` and `toAggregatedMap(keyField...)` add the key field to SELECT and add `WHERE <key> != null`. The methods with a value field (`toMap(key, value)`, `toAggregatedMap(key, value)`) select only the key and value fields.
- `toIdMapBy` and `toMap(keyField)` keep one record per key, and the last record wins. To keep every record, use `toAggregatedIdMapBy` / `toAggregatedMap`.
- Keys and values in the `String` maps, and the values from `toValuesOf`, are the fields' text form, so a Date or a number becomes a `String`.
- `toId`, `toIds`, `doExist`, `toValueOf` and `toInteger` clear the selected fields first, so the selector's default fields cost nothing.
- Don't combine the key-based map methods with `.anyConditionMatching()`. The added `<key> != null` condition is joined with OR, so the query returns every record that has a key. Put the OR conditions in a `SOQL.FilterGroup` instead. `toIdsOf` and `toValuesOf` are not affected.

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
