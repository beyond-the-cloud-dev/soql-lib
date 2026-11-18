---
sidebar_position: 30
---

# Mocking

Mocking provides a way to substitute records from a database with some prepared data. Data can be prepared in the form of SObject records and lists in Apex code or Static Resource `.csv` file.
Mocked queries won't make any SOQLs and simply return data set in method definition. Mock __will ignore all filters and relations__; what is returned depends __solely on data provided to the method__. Mocking works __only during test execution__. To mock a cached query, use the `.mockId(id)` method to make it identifiable. If you mark more than one query with the same ID, all marked queries will return the same data.

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public static Account getPartnerAccount(String accountName) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity)
            .whereEqual(Account.Name, accountName)
            .mockId('ExampleController.getPartnerAccount')
            .toObject();
    }
    
    public static Account getAccountWithParent(String accountName) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .with('Parent', Account.Name)
            .whereEqual(Account.Name, accountName)
            .mockId('ExampleController.getAccountWithParent')
            .toObject();
    }
    
    public static Account getAccountByName(String accountName) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .whereEqual(Account.Name, accountName)
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Then in tests simply pass data you want to get from the cached query to the `SOQLCache.mock(id).thenReturn(data)` method. Acceptable formats are: `SObject`. During execution, the cached query will return the desired data.

## Insights

### Mocking Stack Functionality

SOQL Cache implements a sophisticated mocking system that supports multiple sequential mocks for the same query identifier. This enables complex testing scenarios where the same cached query needs to return different results across multiple executions.

**How the Stack Works:**

Each call to `SOQLCache.mock(mockId)` creates a new mock entry and adds it to a list (stack) associated with that mock ID. When cached queries are executed:

- **Single Mock**: If only one mock exists for the ID, it's reused for all executions
- **Multiple Mocks**: Mocks are consumed in FIFO (First In, First Out) order - each execution removes and returns the first mock from the stack

```apex title="Mock Stack Example"
// Setup multiple sequential mocks
SOQLCache.mock('testQuery').thenReturn(new Account(Name = 'First Call'));
SOQLCache.mock('testQuery').thenReturn(new Account(Name = 'Second Call'));
SOQLCache.mock('testQuery').thenReturn(new Account(Name = 'Third Call'));

// First execution returns "First Call", then removes that mock
Account result1 = (Account) SOQLCache.of(Account.SObjectType)
    .with(Account.Name)
    .whereEqual(Account.Name, 'Test')
    .mockId('testQuery')
    .toObject();

// Second execution returns "Second Call", then removes that mock
Account result2 = (Account) SOQLCache.of(Account.SObjectType)
    .with(Account.Name)
    .whereEqual(Account.Name, 'Test')
    .mockId('testQuery')
    .toObject();

// Third execution returns "Third Call", but does not remove that mock - it's the last mock on the stack
Account result3 = (Account) SOQLCache.of(Account.SObjectType)
    .with(Account.Name)
    .whereEqual(Account.Name, 'Test')
    .mockId('testQuery')
    .toObject();

// Fourth execution returns "Third Call" - it's the last mock on the stack
Account result4 = (Account) SOQLCache.of(Account.SObjectType)
    .with(Account.Name)
    .whereEqual(Account.Name, 'Test')
    .mockId('testQuery')
    .toObject();
```

### Id Field Behavior

The `Id` field is always included in mocked cached results, even if it wasn't explicitly specified. This is designed to mirror standard SOQL behavior — Salesforce automatically includes the `Id` field in every query, even when it's not listed in the `SELECT` clause.

```apex title="Standard SOQL Behavior"
List<Account> accounts = [SELECT Name FROM Account LIMIT 3];
System.debug(accounts);
/* Output:
(
    Account:{Name=Test 1, Id=001J5000008AvzkIAC},
    Account:{Name=Test 2, Id=001J5000008AvzlIAC},
    Account:{Name=Test 3, Id=001J5000008AvzmIAC}
)
*/
```

Similarly, when you mock records using SOQLCache:

```apex title="SOQLCache Mock Example"
SOQLCache.mock('mockingQuery').thenReturn(new List<Account>{
    new Account(Name = 'Test 1'),
    new Account(Name = 'Test 2')
});

List<Account> accounts = (List<Account>) SOQLCache.of(Account.SObjectType)
    .with(Account.Name)
    .allowQueryWithoutConditions()
    .mockId('mockingQuery')
    .toObject(); // Note: SOQLCache typically returns single objects

/* Output includes Id even though not specified:
(
    Account:{Name=Test 1, Id=001J5000008AvzkIAC},
    Account:{Name=Test 2, Id=001J5000008AvzlIAC}
)
*/
```

Even though `Id` wasn't specified in `.with()`, it's automatically added.

## Single record

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccount() {
        SOQLCache.mock('ExampleController.getPartnerAccount').thenReturn(new Account(Name = 'MyAccount 1'));

        // Test
        Account result = ExampleController.getPartnerAccount('MyAccount');

        Assert.areEqual('MyAccount 1', result.Name);
    }
}
```

## Mock by SObjectType

You can also mock cached queries by SObjectType, which applies to all cache queries for that object type without needing specific mock IDs.

```apex title="Controller without Mock ID"
public with sharing class ExampleController {
    public static Account getAnyAccount(String accountName) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity)
            .whereEqual(Account.Name, accountName)
            .toObject();
    }
    
    public static Account getAccountById(Id accountId) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .whereEqual(Account.Id, accountId)
            .toObject();
    }
}
```

Use `SOQLCache.mock(SObjectType)` to mock all cache queries for that SObjectType. This is particularly useful when you have multiple cache methods but want consistent mock data across all of them.

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void testAccountCachingMethods() {
        Account mockAccount = new Account(
            Id = '001000000000001',
            Name = 'Universal Mock Account',
            BillingCity = 'San Francisco'
        );
        
        // This will mock ALL Account cache queries
        SOQLCache.mock(Account.SObjectType).thenReturn(mockAccount);

        // Test first method
        Account result1 = ExampleController.getAnyAccount('Test Account');
        Assert.areEqual('Universal Mock Account', result1.Name);
        
        // Test second method - uses the same mock
        Account result2 = ExampleController.getAccountById('001000000000001');
        Assert.areEqual('Universal Mock Account', result2.Name);
        Assert.areEqual('San Francisco', result2.BillingCity);
    }
}
```

**Important Notes:**
- SObjectType mocking applies to **all** cache queries for that object type within the test context
- It works without requiring `.mockId()` in your cache queries
- Useful for comprehensive testing scenarios where you want consistent mock behavior
- Can be combined with mock ID-specific mocks - ID-specific mocks take precedence

## Parent relationship

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {
    @IsTest
    static void getAccountWithParent() {
        SOQLCache.mock('ExampleController.getAccountWithParent').thenReturn(
            new Account(
                Name = 'Test Account',
                Parent = new Account(Name = 'Parent Account')
            )
        );

        // Test
        Account result = ExampleController.getAccountWithParent('Test Account');

        Assert.areEqual('Test Account', result.Name);
        Assert.areEqual('Parent Account', result.Parent.Name);
    }
}
```

## No Results

Pass an empty list or `null`: `.thenReturn(null)`;
- When `.toObject()` is invoked, it will return `null`.

This behavior will be the same as it is during runtime.

```apex title="ExampleControllerTest.cls"
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQLCache.mock('ExampleController.getAccountByName')
            .thenReturn(null);

        Test.startTest();
        Account result = ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.isNull(result);
    }
}
```

### No Results with SObjectType Mock

You can also return `null` when mocking by SObjectType to simulate no results for all cache queries of that object type.

```apex title="ExampleControllerTest.cls"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void testNoResultsForAllAccountQueries() {
        // Mock all Account cache queries to return null
        SOQLCache.mock(Account.SObjectType).thenReturn(null);

        Test.startTest();
        Account result1 = ExampleController.getAnyAccount('Test');
        Account result2 = ExampleController.getAccountById('001000000000001');
        Test.stopTest();

        Assert.isNull(result1);
        Assert.isNull(result2);
    }
}
```