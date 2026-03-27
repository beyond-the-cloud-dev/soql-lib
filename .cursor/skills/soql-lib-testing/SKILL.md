---
name: soql-lib-testing
description: >-
  Writes unit tests for Salesforce Apex code that uses SOQL Lib (SOQL.cls).
  Covers SOQL.mock() setup by mockId string or SObjectType, thenReturn() for
  records/lists/counts/aggregate results, throwException() mocking, and
  sequential mocks for multiple calls.
  Use when writing @IsTest classes that call SOQL Lib selectors or inline SOQL.of()
  queries, or when asked how to mock SOQL queries in Apex unit tests.
---

# SOQL Lib — Testing & Mocking

SOQL Lib has a built-in mock mechanism — no stub frameworks needed. Mocks are registered **before** calling production code and consumed in registration order.

## When to Use

- Use this skill when writing `@IsTest` classes that test code using SOQL Lib queries
- Use this skill when mocking `SOQL.of(...)` inline queries in unit tests
- Use this skill when testing aggregate queries, exception paths, or COUNT results

## Instructions

### Determine the mock key

Selector classes expose `@TestVisible private static final String MOCK_ID`. Inline queries without a custom `mockId` are mocked by `SObjectType`:

```apex
// Selector
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(records);

// Inline SOQL.of(Account.SObjectType) — no mockId set
SOQL.mock(Account.SObjectType).thenReturn(records);

// Inline SOQL.of(Account.SObjectType).mockId('MyAccounts') — custom mock id
SOQL.mock('MyAccounts').thenReturn(records);
```

Always reference the `MOCK_ID` constant — never repeat the string literal (fragile when class is renamed).

### Register mocks before calling production code

Always register mocks **before** `Test.startTest()`:

```apex
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));

Test.startTest();
List<Account> result = MyService.getAccounts();
Test.stopTest();
```

### thenReturn overloads

```apex
// Single record — pass SObject directly (not a one-element list)
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));

// Multiple records — typed list, never List<SObject>
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>{
    new Account(Name = 'Acme'),
    new Account(Name = 'Globex')
});

// Empty list — test zero-result paths
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());

// COUNT query
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(42);

// Aggregate results — use List<Map<String, Object>> (AggregateResult cannot be instantiated)
SOQL.mock('leadsQuery').thenReturn(new List<Map<String, Object>>{
    new Map<String, Object>{ 'LeadSource' => 'Web',   'total' => 10 },
    new Map<String, Object>{ 'LeadSource' => 'Phone', 'total' => 5 }
});

// Single aggregate result
SOQL.mock('leadsQuery').thenReturn(new Map<String, Object>{ 'total' => 100 });
```

### Exception mocking

```apex
// Default message: 'List has no rows for assignment to SObject'
SOQL.mock(SOQL_Account.MOCK_ID).throwException();

// Custom message
SOQL.mock(SOQL_Account.MOCK_ID).throwException('No such column \'InvalidField__c\'');
```

### Sequential mocks (multiple calls in one test)

Each `SOQL.mock(...)` call appends to the queue and is consumed in order:

```apex
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'First call'));
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Second call'));
```

### Key rules

| Rule | Detail |
|---|---|
| Set mock before production call | Always before `Test.startTest()` |
| Use typed lists | `new List<Account>{...}` — framework strips extra fields to mirror real SOQL |
| Use MOCK_ID constant | Never repeat the string literal |
| Aggregate mocking | Use `toAggregatedProxy()` in production code; mock with `List<Map<String, Object>>` |
| Ids are auto-generated | Records get auto-assigned Ids — no fake prefix strings needed |
| `toObject()` returns null | No exception for 0 rows — test this path explicitly |
| `toObject()` throws for >1 row | When result has multiple records — test this error path too |
| SObjectType mock | `SOQL.mock(Account.SObjectType)` mocks all inline queries for that type without a custom mockId |

## Examples

### Selector — list result

```apex
@IsTest
private class SOQL_Account_Test {

    @IsTest
    static void byType_returnsMatchingAccounts() {
        SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'TechCorp', Type = 'Customer'));

        Test.startTest();
        List<Account> result = SOQL_Account.query()
            .byType('Customer')
            .toList();
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return one account.');
        Assert.areEqual('TechCorp', result[0].Name, 'Account name should match.');
    }

    @IsTest
    static void toObject_returnsNullWhenNoRecords() {
        SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());

        Test.startTest();
        Account result = (Account) SOQL_Account.query().toObject();
        Test.stopTest();

        Assert.isNull(result, 'Should return null when no records found.');
    }

    @IsTest
    static void throwException_propagatesError() {
        SOQL.mock(SOQL_Account.MOCK_ID).throwException();

        Test.startTest();
        Exception caughtEx;
        try {
            SOQL_Account.query().toObject();
        } catch (Exception e) {
            caughtEx = e;
        }
        Test.stopTest();

        Assert.isNotNull(caughtEx, 'Exception should be thrown.');
    }

    @IsTest
    static void throwException_withCustomMessage() {
        String errorMessage = 'No such column \'InvalidField__c\' on entity \'Account\'.';
        SOQL.mock(SOQL_Account.MOCK_ID).throwException(errorMessage);

        Test.startTest();
        Exception caughtEx;
        try {
            SOQL_Account.query().toObject();
        } catch (Exception e) {
            caughtEx = e;
        }
        Test.stopTest();

        Assert.isNotNull(caughtEx);
        Assert.isTrue(caughtEx.getMessage().contains('InvalidField__c'));
    }
}
```

### COUNT query

```apex
@IsTest
static void count_returnsExpectedNumber() {
    SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(7);

    Test.startTest();
    Integer count = SOQL_Account.query().toInteger();
    Test.stopTest();

    Assert.areEqual(7, count, 'Count should match mock value.');
}
```

### Aggregate query (toAggregatedProxy)

```apex
// Production code
public List<SOQL.AggregateResultProxy> getLeadsBySource() {
    return SOQL.of(Lead.SObjectType)
        .with(Lead.LeadSource)
        .count(Lead.Id, 'total')
        .groupBy(Lead.LeadSource)
        .mockId('leadsBySource')
        .toAggregatedProxy();
}

// Test
@IsTest
static void getLeadsBySource_returnsGroupedResults() {
    SOQL.mock('leadsBySource').thenReturn(new List<Map<String, Object>>{
        new Map<String, Object>{ 'LeadSource' => 'Web',   'total' => 10 },
        new Map<String, Object>{ 'LeadSource' => 'Phone', 'total' => 3 }
    });

    Test.startTest();
    List<SOQL.AggregateResultProxy> results = new LeadService().getLeadsBySource();
    Test.stopTest();

    Assert.areEqual(2, results.size());
    Assert.areEqual(10,    (Integer) results[0].get('total'));
    Assert.areEqual('Web', (String)  results[0].get('LeadSource'));
}
```

### Inline query — mock by SObjectType

```apex
// Production code — no selector, no mockId
List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .toList();

// Test — mock by SObjectType
SOQL.mock(Account.SObjectType).thenReturn(new Account(Name = 'Test'));
```

### Inline query — mock by custom mockId

```apex
// Production code
List<Account> accounts = SOQL.of(Account.SObjectType)
    .mockId('MyAccounts')
    .with(Account.Id, Account.Name)
    .toList();

// Test
SOQL.mock('MyAccounts').thenReturn(new Account(Name = 'Test'));
```

### Map result

```apex
@IsTest
static void toMap_returnsAccountsKeyedById() {
    SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));

    Test.startTest();
    Map<Id, Account> result = (Map<Id, Account>) SOQL_Account.query().toMap();
    Test.stopTest();

    Assert.areEqual(1, result.size());
}
```

### Sequential mocks

```apex
@IsTest
static void sequential_consumedInOrder() {
    SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'First'));
    SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Second'));

    Test.startTest();
    List<Account> first  = SOQL_Account.query().toList();
    List<Account> second = SOQL_Account.query().toList();
    Test.stopTest();

    Assert.areEqual('First',  first[0].Name);
    Assert.areEqual('Second', second[0].Name);
}
```
