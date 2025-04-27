---
sidebar_position: 30
---

# Mocking

Mocking provides a way to substitute records from a Database with some prepared data. Data can be prepared in form of SObject records and lists in Apex code or Static Resource `.csv` file.
Mocked queries won't make any SOQL's and simply return data set in method definition, mock __will ignore all filters and relations__, what is returned depends __solely on data provided to the method__. Mocking is working __only during test execution__. To mock SOQL query, use `.mockId(id)` method to make it identifiable. If you mark more than one query with the same ID, all marked queries will return the same data.

```apex
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

Then in test simply pass data you want to get from Selector to `SOQL.mock(id).thenReturn(data)` method. Acceptable formats are: `List<SObject>` or `SObject`. Then during execution Selector will return desired data.

## Insights

### Id Field Behavior

The `Id` field is always included in mocked results, even if it wasn’t explicitly specified. This is designed to mirror standard SOQL behavior — Salesforce automatically includes the `Id` field in every query, even when it’s not listed in the `SELECT` clause.

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
Account `Description` and `Website` are null, even though they were specified. Hovever SOQL specified only for `Account.Name`, so additional field are stripped.

**Note:**
Currently, this field-stripping behavior applies only to simple fields (like `Name`, `Description`, etc.). Relationship fields and subqueries are not yet included in this logic — this may be addressed in future enhancements.

## List of records

```apex
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

```apex
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

```apex
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

```
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.setCountMock('mockingQuery', 2);

        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').toInteger();

        Assert.areEqual(2, result);
    }
}
```

## Sub-Query

To mock a sub-query we need to use deserialization mechanism. There are two approaches, using JSON string or Serialization/Deserialization.
Then after deserialization to desired SObjectType, pass the data to SOQL by calling `.mock` method.


_Using JSON String_

By passing simple String, it is possible to write non-writable fields, like `Name` on Contact object.

```
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

Using this approach it is possible to bind data with additional logic, like using Test Data Factory.

```
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

```
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

## No Results

Pass an empty list: `.thenReturn(new List<Type>())`;
- When `.toList()` is invoked, it will return a `List<Type>`.
- When `.toObject()` is invoked, it will return `null`.

This behavior will be the same as it is during runtime.

```apex
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
