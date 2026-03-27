---
paths:
  - "**/*Test.cls"
  - "**/*_Test.cls"
---

# SOQL Lib — Testing Rules

## Never insert records in tests — always use SOQL.mock()

```apex
// WRONG
Account acc = new Account(Name = 'Acme');
insert acc;

// CORRECT
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));
```

## Always register mocks before Test.startTest()

```apex
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
// Single record — pass SObject directly
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Acme'));

// Multiple records — typed list, not List<SObject>
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>{
    new Account(Name = 'Acme'),
    new Account(Name = 'Globex')
});

// Empty result
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());

// COUNT
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(42);

// Aggregate — AggregateResult cannot be instantiated; use Map
SOQL.mock('leadsQuery').thenReturn(new List<Map<String, Object>>{
    new Map<String, Object>{ 'LeadSource' => 'Web', 'total' => 10 }
});

// Single aggregate result
SOQL.mock('leadsQuery').thenReturn(new Map<String, Object>{ 'total' => 100 });
```

## Always use toAggregatedProxy() in production code when aggregate results need mocking

```apex
// CORRECT production code
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
// No mockId set — mock by SObjectType
SOQL.mock(Account.SObjectType).thenReturn(new Account(Name = 'Test'));

// Custom mockId — mock by key string
SOQL.mock('MyAccounts').thenReturn(new Account(Name = 'Test'));
```

## Sequential mocks for multiple calls to the same query

```apex
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'First'));
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Second'));
```

## Always test the null/empty path for toObject()

`toObject()` returns `null` for 0 rows — never throws. Always add an explicit test for this path.

```apex
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new List<Account>());
Account result = (Account) SOQL_Account.query().toObject();
Assert.isNull(result, 'Should return null when no records found.');
```

## Exception mocking — both variants

```apex
// Default message
SOQL.mock(SOQL_Account.MOCK_ID).throwException();

// Custom message
SOQL.mock(SOQL_Account.MOCK_ID).throwException('No such column \'InvalidField__c\'');
```

## Never generate fake Id strings — SOQL Lib auto-assigns Ids

```apex
// WRONG
Account acc = new Account(Id = '001000000000001AAA', Name = 'Test');

// CORRECT — framework assigns a valid synthetic Id automatically
SOQL.mock(SOQL_Account.MOCK_ID).thenReturn(new Account(Name = 'Test'));
```
