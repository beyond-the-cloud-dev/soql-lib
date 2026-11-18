# SOQL Lib: Less Common Clauses

## Contents
- USING SCOPE
- FOR and ALL ROWS
- WITH DATA CATEGORY
- TYPEOF (polymorphic lookups)
- DISTANCE (geolocation)
- toLabel, FORMAT and field aliases
- Runtime-built (dynamic) queries
- Cursors and batch
- Logging failed queries

## USING SCOPE

```apex
.mineScope()              // USING SCOPE MINE
.mineAndMyGroupsScope()   // USING SCOPE MINE_AND_MY_GROUPS (ProcessInstanceWorkItem)
.delegatedScope()         // USING SCOPE DELEGATED
.myTerritoryScope()       // USING SCOPE MY_TERRITORY
.myTeamTerritoryScope()   // USING SCOPE MY_TEAM_TERRITORY
.teamScope()              // USING SCOPE TEAM
```

## FOR and ALL ROWS

```apex
.forUpdate()      // FOR UPDATE: lock the rows for this transaction
.forView()        // FOR VIEW: update LastViewedDate
.forReference()   // FOR REFERENCE: update LastReferencedDate
.allRows()        // ALL ROWS: include deleted and archived records
```

A query holds only one of these keywords, and the last call wins. `.forView().forUpdate()` keeps only `FOR UPDATE`. Don't combine `forUpdate()` with `orderBy(...)`, because Salesforce rejects ORDER BY in a locking query.

## WITH DATA CATEGORY

```apex
SOQL.of(Knowledge__kav.SObjectType)
    .with(Knowledge__kav.Id, Knowledge__kav.Title)
    .withDataCategory(SOQL.DataCategoryFilter.with('Geography__c').at('Europe__c'))
    .toList();
```

Comparators: `at`, `above`, `below`, `aboveOrBelow`. Each takes one category or a list of categories.

## TYPEOF (polymorphic lookups)

```apex
SOQL.of(Event.SObjectType)
    .with(Event.Subject)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType).then(Account.Phone, Account.NumberOfEmployees)
        .when(Opportunity.SObjectType).then(Opportunity.Amount)
        .whenElse('Name'))
    .toList();
```

Read the values with `eventRecord.What.get('Phone')`. Don't name the variable `event`, because it would shadow the `Event` type. Grouped and `COUNT()` queries drop TYPEOF fields.

## DISTANCE (geolocation)

```apex
SOQL.Distance distance = SOQL.Distance.of(Contact.MailingAddress).between(52.23, 21.01).km();

SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(distance).lessThan(10))
    .orderBy(distance)
    .toList();
```

`between` also accepts a `System.Location`. The units are `.mi()` and `.km()`, and the default is km.

## toLabel, FORMAT and field aliases

```apex
.toLabel(Lead.Status)                  // SELECT toLabel(Status)
.toLabel(Lead.Status, 'statusLabel')   // SELECT toLabel(Status) statusLabel
.toLabel('RecordType.Name')
.format(Opportunity.Amount)            // SELECT FORMAT(Amount)
.format(Opportunity.Amount, 'amount')  // SELECT FORMAT(Amount) amount
.with(Lead.LeadSource, 'source')       // grouped field under an alias (aggregate queries only)
```

## Runtime-built (dynamic) queries

Only use these when the object, the fields or the conditions are not known at compile time.

```apex
SOQL.of(objectApiName)                      // String API name
    .with(fieldNames)                        // List<String>: an empty list adds nothing
    .whereAre(SOQL.Filter.with(fieldName).equal(value))  // value is still bound
    .orderBy(sortField, sortDirection)       // 'ASC' / 'DESC'
    .toList();
```

Only the comparator values are bound here. The object name, the field names and the sort direction go into the SOQL text as written. Before using them, check names that come from outside the code against the schema (`Schema.getGlobalDescribe()`, the object's `fields.getMap()`), and accept only `ASC` / `DESC`. `whereAre(String)`, `FilterGroup.add(String)` and `have(String)` insert raw text that is not bound, so never put user input in that text.

## Cursors and batch

```apex
Database.QueryLocator locator = SOQL_Account.query().toQueryLocator();   // Batch Apex start()
Database.Cursor cursor = SOQL_Account.query().toCursor();                // cursor.fetch(position, count)
Database.PaginationCursor page = SOQL_Account.query().orderBy(Account.Name).toPaginationCursor();
```

Mocks don't apply to these three methods, because they return platform cursor objects.

## Logging failed queries

Create one top-level, concrete class that implements `SOQL.Logger`. SOQL Lib finds it automatically, so no registration is needed. It is called only when a query throws, and the original exception is rethrown afterwards. Mocked exceptions are not logged.

```apex
public class SOQLQueryLogger implements SOQL.Logger {
    public void log(SOQL.Error error) {
        // error.getException(), error.getQuery(), error.getBinding(), error.getAccessLevel()
    }
}
```

`log()` must not throw, because its exception would replace the original query error. `getBinding()` returns SOQL Lib's shared bind map, which the next query clears. If you keep the bindings after `log()` returns, copy them first: `new Map<String, Object>(error.getBinding())`.
