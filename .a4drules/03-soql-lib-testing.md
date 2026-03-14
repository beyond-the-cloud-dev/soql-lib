# SOQL Lib — Testing Rules

## Never insert records in tests — always use SOQL.mock()

Never use `insert` DML in unit tests to set up query data. Use the SOQL Lib mock mechanism instead.

```apex
// WRONG
Account acc = new Account(Name = 'Acme');
insert acc;
List<Account> result = SOQL_Account.query().toList();

// CORRECT
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));
List<Account> result = SOQL_Account.query().toList();
```

## Always register mocks before Test.startTest()

```apex
// WRONG
Test.startTest();
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));
List<Account> result = MyService.getAccounts();
Test.stopTest();

// CORRECT
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));

Test.startTest();
List<Account> result = MyService.getAccounts();
Test.stopTest();
```

## Always reference MOCK_ID constant — never repeat the string literal

```apex
// WRONG — fragile when class is renamed
SOQL.mock('SOQL_Account').thenReturn(record);

// CORRECT
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(record);
```

## Use the correct thenReturn() overload

```apex
// Single record — pass the SObject directly, not a one-element list
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));

// Multiple records — use a typed list (never List<SObject>)
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>{
    new Account(Name = 'Acme'),
    new Account(Name = 'Globex')
});

// Empty result
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());

// COUNT
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(42);

// Aggregate (AggregateResult cannot be instantiated — use Map)
SOQL.mock('leadsQuery').thenReturn(new List<Map<String, Object>>{
    new Map<String, Object>{ 'LeadSource' => 'Web', 'total' => 10 }
});
```

## Always use toAggregatedProxy() in production code when aggregate results need mocking

```apex
// WRONG — toAggregated() cannot be mocked
public List<AggregateResult> getLeadsBySource() {
    return SOQL.of(Lead.SObjectType)
        .count(Lead.Id, 'total')
        .groupBy(Lead.LeadSource)
        .toAggregated();
}

// CORRECT
public List<SOQL.AggregateResultProxy> getLeadsBySource() {
    return SOQL.of(Lead.SObjectType)
        .count(Lead.Id, 'total')
        .groupBy(Lead.LeadSource)
        .mockId('leadsBySource')
        .toAggregatedProxy();
}
```

## Mock inline queries by SObjectType or custom mockId

```apex
// Inline query with no mockId — mock by SObjectType
SOQL.mock(Account.SObjectType).thenReturn(new Account(Name = 'Test'));

// Inline query with .mockId('key') — mock by key string
SOQL.mock('MyAccounts').thenReturn(new Account(Name = 'Test'));
```

## Sequential mocks for multiple calls to the same query

Each `SOQL.mock(...)` call is appended to the queue and consumed in registration order.

```apex
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'First'));
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Second'));
```

## Always test the null/empty path for toObject()

`toObject()` returns `null` for 0 rows — it never throws. Always add an explicit test for this path.

```apex
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());

Account result = (Account) SOQL_Account.query().toObject();

Assert.isNull(result, 'Should return null when no records found.');
```

## Never generate fake Id strings — SOQL Lib auto-assigns Ids

```apex
// WRONG
Account acc = new Account(Id = '001000000000001AAA', Name = 'Test');

// CORRECT — framework assigns a valid synthetic Id automatically
Account acc = new Account(Name = 'Test');
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(acc);
```
