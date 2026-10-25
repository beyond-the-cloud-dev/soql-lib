---
name: soql-lib-testing
description: Apex unit tests for code that queries through SOQL Lib, using SOQL.mock() instead of inserted records. Use when writing or fixing @IsTest classes for services, controllers, batches or selectors that use SOQL_Account-style selectors or SOQL.of(...), when mocking query results, counts, aggregate results or query exceptions, or when a mocked SOQL Lib query returns unexpected data, in a project that contains SOQL.cls.
---

# SOQL Lib: Testing with Mocks

`SOQL.mock(<key>).thenReturn(<data>)` makes every query with that key return the given data without touching the database. To test code that reads records, mock its queries instead of inserting the records.

## Rules

1. Supply query results with mocks. Use DML only when the test is about DML itself, or about filtering that only the database can do (see "Testing selector filters").
2. Register every mock before the code under test builds its query, which in practice means before you call that code (and before `Test.startTest()` if you use it). A query built before its mock existed never sees the mock.
3. Reference the selector's constant, `SOQL.mock(SOQL_Account.MOCK_ID)`. Never repeat the string `'SOQL_Account'`. `MOCK_ID` is `@TestVisible private`, so test classes can read it even though it is private.
4. Mock with the key the query really uses:

| Production query | Mock key |
|---|---|
| `SOQL_Account.query()...` | `SOQL.mock(SOQL_Account.MOCK_ID)` |
| `....mockId('AccountService.getTop')`, inline or on a selector | `SOQL.mock('AccountService.getTop')` |
| `SOQL.of(Account.SObjectType)` or `SOQL.of('Account')` without `mockId` | `SOQL.mock(Account.SObjectType)` |

- A `.mockId(...)` at the call site replaces the selector's `MOCK_ID`.
- `SOQL.mock(Account.SObjectType)` does not catch selector queries, because those use `MOCK_ID`.
- A query with no matching mock runs against the test database, which is empty unless the test inserted data.

## thenReturn by result method

| Production code calls | Mock data |
|---|---|
| `toList`, `toObject`, `toMap*`, `toIdMapBy`, `toAggregatedMap`, `toIds`, `toIdsOf`, `toValueOf`, `toValuesOf`, `doExist` | `new Account(...)` or a typed `new List<Account>{ ... }` |
| No rows | `new List<Account>()`: `toObject()` returns `null`, `doExist()` returns `false` |
| `toInteger()` | an `Integer`: `thenReturn(3)` |
| `toAggregatedProxy()` | `new List<Map<String, Object>>{ new Map<String, Object>{ 'StageName' => 'Won', 'total' => 25000.00 } }`, or one `Map<String, Object>` |
| A query that fails | `.throwException()` (message `List has no rows for assignment to SObject`) or `.throwException('custom message')`. Both throw `QueryException`. |

- `toAggregated()` can't be mocked, because `AggregateResult` can't be constructed. Production code that needs a mocked aggregate must use `toAggregatedProxy()`.
- `toQueryLocator()`, `toCursor()` and `toPaginationCursor()` ignore mocks.
- An aggregate query without GROUP BY returns one row even when no records match, and its values are `null`. Mock that case with `new Map<String, Object>{ 'total' => null }`. A grouped query with no matches returns no rows, so mock it with `new List<Map<String, Object>>()`.
- In aggregate maps, use the type the real query returns: `Integer` for `COUNT`, `Decimal` for `SUM` / `AVG` / `MIN` / `MAX` of number or currency fields. Casting a mocked `Decimal` to `Integer` throws `Invalid conversion from runtime type Decimal to Integer`.
- With two or more rows in the mock, `toObject()` throws `List has more than 1 row for assignment to SObject`, the same as a real query.

## How mocks behave

- They ignore WHERE, ORDER BY, LIMIT, OFFSET and HAVING, and return exactly the data you gave.
- They add an `Id` to records that have none.
- They strip plain fields the query doesn't select, keeping only `Id`, the selected fields and the selected subqueries. If the test reads a field, the production query must select it. Queries with parent fields, TYPEOF, `toLabel` or `FORMAT` return the records unchanged.
- Calling `SOQL.mock` again with the same key queues another result. Executions consume the queue in order, and the last result is reused for every later execution.
- Mocked queries count toward the 100-query limit. In synchronous tests, `SOQL.getQueries()` returns the number issued, mocks included, so you can assert that nothing queries inside a loop.
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
- Polymorphic lookups (TYPEOF): `event.putSObject('What', new Account(Name = 'Acme'))`.

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
| `NullPointerException` in `SOQL.SObjectMock.get`, or `Use toAggregatedProxy() to mock AggregateResult records.` | Production code calls `.toAggregated()` on a mocked query | Switch it to `.toAggregatedProxy()` |
| `Invalid conversion from runtime type Decimal to Integer` | `COUNT` mocked with a Decimal | Mock counts with `Integer` values |
| `SOQL.mock(Account.SObjectType)` has no effect | The code uses `SOQL_Account` | `SOQL.mock(SOQL_Account.MOCK_ID)` |
| A second call returns the first call's data | Only one mock is registered, so it is reused | Register one `SOQL.mock` per expected execution |
