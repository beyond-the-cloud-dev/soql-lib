---
sidebar_position: 30
---

# Mocking

Mocking provides a way to substitute records from a database with some prepared data. Data can be prepared in the form of SObject records and lists in Apex code or Static Resource `.csv` file.
Mocked queries won't make any SOQLs and simply return data set in method definition. Mock __will ignore all filters and relations__; what is returned depends __solely on data provided to the method__. Mocking works __only during test execution__. To mock a SOQL query, use the `.mockId(id)` method to make it identifiable. If you mark more than one query with the same ID, all marked queries will return the same data.

```apex title="ExampleController.cls"
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .toList();
    }
}
```

Then in tests simply pass data you want to get from the Selector to the `SOQL.mock(id).thenReturn(data)` method. Acceptable formats are: `List<SObject>`, `SObject`, `Integer` (for count queries), or `List<Map<String, Object>>` (for aggregate results). During execution, the Selector will return the desired data.

## Insights

### Mocking Stack Functionality

SOQL Lib implements a sophisticated mocking system that supports multiple sequential mocks for the same query identifier. This enables complex testing scenarios where the same query needs to return different results across multiple executions.

**How the Stack Works:**

Each call to `SOQL.mock(mockId)` creates a new mock entry and adds it to a list (stack) associated with that mock ID. When queries are executed:

- **Single Mock**: If only one mock exists for the ID, it's reused for all executions
- **Multiple Mocks**: Mocks are consumed in FIFO (First In, First Out) order - each execution removes and returns the first mock from the stack

```apex
// Setup multiple sequential mocks
SOQL.mock('testQuery').thenReturn(new Account(Name = 'First Call'));
SOQL.mock('testQuery').thenReturn(new Account(Name = 'Second Call'));
SOQL.mock('testQuery').thenReturn(new Account(Name = 'Third Call'));

// First execution returns "First Call", then removes that mock
Account result1 = SOQL.of(Account.SObjectType).mockId('testQuery').toObject();

// Second execution returns "Second Call", then removes that mock
Account result2 = SOQL.of(Account.SObjectType).mockId('testQuery').toObject();

// Third execution returns "Third Call", but do not removes that mock - it's the last mock on the stack
Account result3 = SOQL.of(Account.SObjectType).mockId('testQuery').toObject();

// Fourth execution returns "Third Call" - it's the last mock on the stack
Account result4 = SOQL.of(Account.SObjectType).mockId('testQuery').toObject();
```

### Id Field Behavior

The `Id` field is always included in mocked results, even if it wasn't explicitly specified. This is designed to mirror standard SOQL behavior — Salesforce automatically includes the `Id` field in every query, even when it's not listed in the `SELECT` clause.

```apex
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

Similarly, when you mock records using SOQL Lib:

```apex
SOQL.mock('mockingQuery').thenReturn(new List<Account>{
    new Account(Name = 'Test 1'),
    new Account(Name = 'Test 2')
});

List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Name)
    .mockId('mockingQuery')
    .toList();

/* Output:
(
    Account:{Name=Test 1, Id=001J5000008AvzkIAC},
    Account:{Name=Test 2, Id=001J5000008AvzlIAC}
)
*/
```

Even though `Id` wasn’t specified in `.with()`, it’s automatically added.

### Stripping Additional Fields

When using test data factories or builders, it’s common to generate records populated with many fields. However, SOQL Lib ensures that only the fields specified in the query are retained — all other fields are stripped to simulate real SOQL behavior.

```apex
// Setup
List<Account> accounts = new List<Account>{
    new Account(Name = 'Test 1', Description = 'Test 1 Description', Website = 'www.beyondthecloud.dev'),
    new Account(Name = 'Test 2', Description = 'Test 2 Description', Website = 'www.beyondthecloud.dev')
};

// Test
SOQL.mock('mockingQuery').thenReturn(accounts);

List<Account> result = SOQL.of(Account.SObjectType)
    .with(Account.Name)
    .mockId('mockingQuery')
    .toList();

for (Account mockedResult : result) {
    Assert.isTrue(mockedResult.isSet(Account.Name), 'Only Account Name should be set.');
    Assert.isNull(mockedResult.Description, 'The Account Description should not be set because it was not included in the SELECT clause.');
    Assert.isNull(mockedResult.Website, 'The Account Website should not be set because it was not included in the SELECT clause.');
}
```

In this case:
- Although `Description` and `Website` were present in the mocked data, they are removed because they weren’t part of the query.
- Only fields explicitly defined in `.with()` (plus `Id` by default) remain.
Account `Description` and `Website` are null, even though they were specified. However, SOQL specified only `Account.Name`, so additional fields are stripped.

**Note:**
Currently, this field-stripping behavior applies only to simple fields (such as `Name`, `Description`, etc.) and subqueries. Additional subqueries are also removed — only the explicitly queried subqueries remain.

Relationship fields and queries using functions are not yet covered by this logic. This means that SOQL queries involving relationship records or functions (like `COUNT`, `AVG`) will return the exact mock defined in the unit test. This may be addressed in future enhancements.

### Queries Issued Count

Mocked queries in SOQL Lib are counted towards the SOQL query limit, just like real queries. If the number of issued queries exceeds the limit, SOQL Lib will throw:

```apex
QueryException: Too many SOQL queries.
```

This behavior is consistent with Salesforce’s native limits, ensuring that your unit tests accurately reflect potential production scenarios.

## List of records

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.mock('ExampleController.getPartnerAccounts').thenReturn(accounts);

        // Test
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual(accounts, result);
    }
}
```

## Single record

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccount() {
        SOQL.mock('ExampleController.getPartnerAccount').thenReturn(new Account(Name = 'MyAccount 1'));

        // Test
        Account result = (Account) ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual('MyAccount 1', result.Name);
    }
}
```

## Static resource

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.mock('ExampleController.getPartnerAccounts').thenReturn(Test.loadData(Account.SObjectType, 'ProjectAccounts'));

        // Test
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual(5, result.size());
    }
}
```

## Count Result

```apex title="ExampleControllerTest.cls"
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.mock('mockingQuery').thenReturn(2);

        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').toInteger();

        Assert.areEqual(2, result);
    }
}
```

## Sub-Query

To mock a sub-query, we need to use a deserialization mechanism. There are two approaches: using JSON string or Serialization/Deserialization.
After deserialization to the desired SObjectType, pass the data to SOQL by calling the `.mock` method.


_Using JSON String_

By passing a simple String, it is possible to write non-writable fields, like `Name` on the Contact object.

```apex
@IsTest
static void getAccountsWithContacts() {
    List<Account> mocks = (List<Account>) JSON.deserialize(
        '[{ "Name": "Account Name", "Contacts": { "totalSize": 1, "done": true, "records": [{ "Name": "Contact Name", "Email": "contact.email@address.com" }] }  }],
        List<Account>.class
    );

    SOQL.mock('AccountsController.getAccountsWithContacts').thenReturn(mocks);

    List<Account> accounts;

    Test.startTest();
    accounts = AccountsController.getAccountsWithContacts();
    Test.stopTest();

    Assert.isNotNull(accounts);
    Assert.isNotNull(accounts[0].contacts);
    Assert.areEqual(1, accounts[0].contacts.size());
}
```

_Using Serialization/Deserialization_

Using this approach, it is possible to bind data with additional logic, like using a Test Data Factory.

```apex
@IsTest
static void getAccountsWithContacts() {
    List<Account> mocks = (List<Account>) JSON.deserialize(
        JSON.serialize(
            new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Name' => 'Account Name',
                    'Contacts' => new Map<String, Object>{
                        'totalSize' => 1,
                        'done' => true,
                        'records' => new List<Contact>{ new Contact(FirstName = 'Contact', LastName = 'Name', Email = 'contact.email@address.com') }
                    }
                }
            }
        ),
        List<Account>.class
    );

    SOQL.mock('AccountsController.getAccountsWithContacts').thenReturn(mocks);

    List<Account> accounts;

    Test.startTest();
    accounts = AccountsController.getAccountsWithContacts();
    Test.stopTest();

    Assert.isNotNull(accounts);
    Assert.isNotNull(accounts[0].contacts);
    Assert.areEqual(1, accounts[0].contacts.size());
}
```

## Parent relationship

```apex
@IsTest
private class ExampleControllerTest {
    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.mock('mockingQuery').thenReturn(
            new Account(
                Name = 'Test',
                Parent = new Account(Name = 'Parent Name')
            )
        );

        Account result = (Account) ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual(2, result);
    }
}
```

## AggregateResult

There is no way to create a `new AggregateResult()` instance in Apex. You can find more details here: [AggregateResult mocking consideration](https://github.com/beyond-the-cloud-dev/soql-lib/discussions/171).

To mock `AggregateResult`, we introduced `SOQL.AggregateResultProxy`, which provides the same methods as the standard `AggregateResult` class.

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public void getLeadAggregateResults() {
        List<SOQL.AggregateResultProxy> result = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource)
            .COUNT(Lead.Id, 'total')
            .groupBy(Lead.LeadSource)
            .mockId('ExampleController.getLeadAggregateResults')
            .toAggregatedProxy(); // <== use toAggregatedProxy()
    }
}
```

```apex title="ExampleControllerTest.cls"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getLeadAggregateResults() {
        List<Map<String, Object>> aggregateResults = new List<Map<String, Object>>{
            new Map<String, Object>{ 'LeadSource' => 'Web',  'total' => 10},
            new Map<String, Object>{ 'LeadSource' => 'Phone', 'total' => 5},
            new Map<String, Object>{ 'LeadSource' => 'Email', 'total' => 3}
        };

        SOQL.mock('ExampleController.getLeadAggregateResults').thenReturn(aggregateResults);

        Test.startTest();
        List<SOQL.AggregateResultProxy> result = ExampleController.getLeadAggregateResults();
        Test.stopTest();

        // Assert
        Assert.areEqual(3, result.size(), 'The size of the aggregate results should match the mocked size.');
    }
}
```

## No Results

Pass an empty list: `.thenReturn(new List<Type>())`;
- When `.toList()` is invoked, it will return a `List<Type>`.
- When `.toObject()` is invoked, it will return `null`.

This behavior will be the same as it is during runtime.

```apex title="ExampleControllerTest.cls"
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQL.mock('ExampleController.getAccountByName')
            .thenReturn(new List<Account>());

        Test.startTest();
        Account result = (Account) ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.isNull(result);
    }
}
```

# toIdsOf, toValuesOf

We are using field aliasing: https://salesforce.stackexchange.com/questions/393308/get-a-list-of-one-column-from-a-soql-result

It’s approximately 2x more efficient than a standard for loop. Because of this, mocking works differently for the following methods:

- `toIdsOf(SObjectField field)`
- `toIdsOf(String relationshipName, SObjectField field)`
- `toValuesOf(SObjectField fieldToExtract)`
- `toValuesOf(String relationshipName, SObjectField targetKeyField)`

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public Set<String> getAccountNames() {
        return SOQL.of(Account.SObjectType)
            .mockId('ExampleController.getAccountNames')
            .toValuesOf(Account.Name);
    }
}
```

```apex title="ExampleControllerTest.cls"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountByName() {
         SOQL.mock('mockingQuery').thenReturn(
            (List<AggregateResult>) JSON.deserialize(
                JSON.serialize(new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'Id' => 'Account Name 1'
                    },
                    new Map<String, Object>{
                        'Id' => 'Account Name 2'
                    }
                }),
                List<AggregateResult>.class
            )
        );

        Test.startTest();
        Set<String> result = ExampleController.getAccountNames();
        Test.stopTest();

        Assert.areEqual(2, result.size());
    }
}
```
