---
name: soql-lib-testing
description: Apex unit tests for code that queries through SOQL Lib, using SOQL.mock() instead of inserted records. Use when writing or fixing @IsTest classes for services, controllers, batches or selectors that use SOQL_Account-style selectors or SOQL.of(...), when mocking query results, counts, aggregate results or query exceptions, or when a mocked SOQL Lib query returns unexpected data, in a project that contains SOQL.cls.
---

# SOQL Lib: Testing with Mocks

`SOQL.mock(<key>).thenReturn(<data>)` makes every query with that key return the given data without touching the database. To test code that reads records, mock its queries instead of inserting the records.

## Rules

1. Supply query results with mocks. Use DML only when the test is about DML itself, about filtering that only the database can do (see "Testing selector filters"), or about `toQueryLocator()` / `toCursor()` / `toPaginationCursor()`, which ignore mocks.
2. Register every mock before the code under test builds its query, which in practice means before you call that code. The mock is looked up when the query is built, so a query built before any mock existed for its key never sees one. Registering mocks before `Test.startTest()` is a convention, not a requirement.
3. Reference the selector's constant, `SOQL.mock(SOQL_Account.MOCK_ID)`. Never repeat the string `'SOQL_Account'`. `MOCK_ID` is `@TestVisible private`, so test classes can read it even though it is private.
4. Mock with the key the query really uses:

| Production query | Mock key |
|---|---|
| `SOQL_Account.query()...` | `SOQL.mock(SOQL_Account.MOCK_ID)` |
| `....mockId('AccountService.getTop')`, inline or on a selector | `SOQL.mock('AccountService.getTop')` |
| `SOQL.of(Account.SObjectType)`, or `SOQL.of('Account')` spelled exactly like the API name, without `mockId` | `SOQL.mock(Account.SObjectType)` |
| `SOQLCache` / `SOQLEvaluator` queries | `SOQLCache.mock(...)` / `SOQLEvaluator.mock(...)`, because `SOQL.mock` doesn't reach them |

- A `.mockId(...)` at the call site replaces the selector's `MOCK_ID`.
- `SOQL.mock(Account.SObjectType)` does not catch selector queries, because those use `MOCK_ID`.
- A query with no matching mock runs against the test database, which is empty unless the test inserted data.

## thenReturn by result method

| Production code calls | Mock data |
|---|---|
| `toList`, `toObject`, `toId`, `toIds`, `toIdsOf`, `toValueOf`, `toValuesOf`, `toMap`, `toIdMapBy`, `toAggregatedMap`, `toAggregatedIdMapBy`, `doExist` | `new Account(...)` or a typed `new List<Account>{ ... }` |
| No rows | `new List<Account>()`: `toObject()` returns `null`, `doExist()` returns `false` |
| `toInteger()` | an `Integer`: `thenReturn(3)` |
| `toAggregatedProxy()` | `new List<Map<String, Object>>{ new Map<String, Object>{ 'StageName' => 'Won', 'total' => 25000.00 } }`, or one `Map<String, Object>` |
| A query that fails | `.throwException()` (message `List has no rows for assignment to SObject`) or `.throwException('custom message')`. Both throw `QueryException`. |

- `toAggregated()` can't be mocked, because `AggregateResult` can't be constructed. Production code that needs a mocked aggregate must use `toAggregatedProxy()`.
- `toQueryLocator()`, `toCursor()` and `toPaginationCursor()` ignore mocks.
- An aggregate query without GROUP BY returns one row even when no records match. `COUNT` and `COUNT_DISTINCT` are `0`, and `SUM`, `AVG`, `MIN` and `MAX` are `null`. Mock that case the same way, for example `new Map<String, Object>{ 'total' => null }`. A grouped query with no matches returns no rows, so mock it with `new List<Map<String, Object>>()`.
- The data type must match the result method. A mock that holds only an `Integer` or aggregate maps makes `toList()` and the other record methods throw a `NullPointerException` in `SOQL.SObjectMock.get`. A mock that holds only records makes `toInteger()` return `null` and `toAggregatedProxy()` return an empty list.
- In aggregate maps, use the type the real query returns: `Integer` for `COUNT`, `Decimal` for `SUM` / `AVG` / `MIN` / `MAX` of number or currency fields. Casting a mocked `Decimal` to `Integer` throws `Invalid conversion from runtime type Decimal to Integer`.
- With two or more rows in the mock, `toObject()` throws `List has more than 1 row for assignment to SObject`, the same as a real query.

## How mocks behave

- They ignore WHERE, ORDER BY, LIMIT, OFFSET and HAVING, and return exactly the data you gave. That includes the `<key> != null` condition the result methods add. The real query would skip a record whose key field is null, but in a mock that record makes `toIdsOf` / `toValuesOf` throw `ListException: Row with null Id at index: 0` and gives `toMap(field)` a `null` key. So set the key field on every mocked record.
- They add an `Id` to records that have none, except for objects without an Id key prefix.
- They strip plain fields the query doesn't select, keeping only `Id`, the selected fields and the selected subqueries. If the test reads a field, the production query must select it. Queries with parent fields, TYPEOF, `toLabel` or `FORMAT` are not stripped, but still get Ids.
- Calling `SOQL.mock` again with the same key queues another result. Executions consume the queue in order, and the last result is reused for every later execution.
- An exception mock is never consumed. Once it reaches the front of the queue, every later execution throws, so register it last or on its own.
- SOQL Lib counts its own queries in synchronous tests, mocks included, and throws a catchable `QueryException: Too many SOQL queries.` above 100. `SOQL.getQueries()` returns that count, so you can assert that nothing queries inside a loop. The count isn't reset by `Test.startTest()`, and `toIdsOf`, `toValuesOf` and mocked `toAggregatedProxy()` calls aren't counted.
- Mocked exceptions are not passed to `SOQL.Logger`.

## Example

```apex
// Production code
public with sharing class AccountHealthService {
    public static String describeAccount(Id accountId) {
        Account accountRecord = (Account) SOQL_Account.query().byId(accountId).with(Account.Industry).toObject();
        if (accountRecord == null) {
            return 'Missing';
        }
        Integer openCount = SOQL.of(Opportunity.SObjectType)
            .whereAre(SOQL.Filter.with(Opportunity.AccountId).equal(accountId))
            .whereAre(SOQL.Filter.with(Opportunity.IsClosed).isFalse())
            .toInteger();
        return accountRecord.Name + ' (' + accountRecord.Industry + '): ' + openCount + ' open';
    }
}
```

```apex
@IsTest
private class AccountHealthServiceTest {
    @IsTest
    static void describeAccountWithOpenOpportunities() {
        SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme', Industry = 'Energy'));
        SOQL.mock(Opportunity.SObjectType).thenReturn(3);

        Test.startTest();
        String result = AccountHealthService.describeAccount(SOQL.IdGenerator.get(Account.SObjectType));
        Test.stopTest();

        Assert.areEqual('Acme (Energy): 3 open', result, 'Should combine account data with the open opportunity count.');
    }

    @IsTest
    static void describeMissingAccount() {
        SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());

        Test.startTest();
        String result = AccountHealthService.describeAccount(SOQL.IdGenerator.get(Account.SObjectType));
        Test.stopTest();

        Assert.areEqual('Missing', result, 'Should report a missing account when the query returns no rows.');
    }

    @IsTest
    static void describeAccountQueryFails() {
        SOQL.mock(SOQL_Account.MOCK_ID).throwException('Account query failed');

        Exception thrown;
        Test.startTest();
        try {
            AccountHealthService.describeAccount(SOQL.IdGenerator.get(Account.SObjectType));
        } catch (QueryException e) {
            thrown = e;
        }
        Test.stopTest();

        Assert.areEqual('Account query failed', thrown?.getMessage(), 'Should propagate the query exception.');
    }
}
```

## Test data shapes

- Ids passed to the code under test: `SOQL.IdGenerator.get(Account.SObjectType)`, never hard-coded Id strings.
- Parent fields: `new Contact(LastName = 'Doe', Account = new Account(Name = 'Acme'))`.
- Child subquery rows, and fields you can't write such as formula fields, `CreatedDate` or `Contact.Name`: build the records with JSON.
  ```apex
  List<Account> accounts = (List<Account>) JSON.deserialize(
      '[{"Name":"Acme","Contacts":{"totalSize":1,"done":true,"records":[{"LastName":"Doe"}]}}]',
      List<Account>.class
  );
  ```
- Polymorphic lookups (TYPEOF): `eventRecord.putSObject('What', new Account(Name = 'Acme'))`. Don't name the variable `event`, because it shadows the `Event` type.

## Testing selector filters

Mocks ignore WHERE, so a mocked test can't prove that a selector filter is correct. Assert the generated SOQL instead. Values appear as bind names.

```apex
String soql = SOQL_Opportunity.query().isOpen().toString();
Assert.isTrue(soql.endsWith('FROM Opportunity WHERE IsClosed = :v1'), 'isOpen() should filter on IsClosed: ' + soql);
```

To verify the data a filter returns, write a test that inserts records and doesn't register a mock.

## Common mistakes

| Symptom | Cause | Fix |
|---|---|---|
| Mock ignored, real query runs | Mock registered after the query was built, or the wrong key | Move `SOQL.mock` up, and check the key table |
| Field is `null` in the result | The query doesn't select it, so the mock stripped it | Select the field in production code, or stop asserting it |
| `Use toAggregatedProxy() to mock AggregateResult records.` | A mocked query with aggregate functions or `.with(field, alias)` is read with `toList()` or `toAggregated()` | Read it with `.toAggregatedProxy()` and mock it with maps |
| `NullPointerException` in `SOQL.SObjectMock.get` | The mock holds no records (only an `Integer` or maps), but a record method or `toAggregated()` runs | Match the mock data to the result method |
| `toInteger()` returns `null` | The count query was mocked with records | Mock it with an `Integer` |
| `ListException: Row with null Id at index: 0` from a mocked `toIdsOf` / `toValuesOf` | A mocked record has the extracted field empty | Set that field on every mocked record |
| Every execution throws after the first exception | An exception mock is never consumed | Register it last, or on its own |
| `Invalid conversion from runtime type Decimal to Integer` | `COUNT` mocked with a Decimal | Mock counts with `Integer` values |
| `SOQL.mock(Account.SObjectType)` has no effect | The code uses `SOQL_Account` | `SOQL.mock(SOQL_Account.MOCK_ID)` |
| A second call returns the first call's data | Only one mock is registered, so it is reused | Register one `SOQL.mock` per expected execution |
