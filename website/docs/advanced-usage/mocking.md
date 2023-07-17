---
sidebar_position: 3
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

Then in test simply pass data you want to get from Selector to `SOQL.setMock(id, data)` method. Acceptable formats are: `List<SObject>` or `SObject`. Then during execution Selector will return desired data.

### List of records

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.setMock('ExampleController.getPartnerAccounts', accounts);

        // Test
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual(accounts, result);
    }
}
```

### Single record

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccount() {
        SOQL.setMock('ExampleController.getPartnerAccount', new Account(Name = 'MyAccount 1'));

        // Test
        Account result = (Account) ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual('MyAccount 1', result.Name);
    }
}
```

### Static resource

```apex
@IsTest
private class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.setMock('ExampleController.getPartnerAccounts', Test.loadData(Account.SObjectType, 'ProjectAccounts'));

        // Test
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');

        Assert.areEqual(5, result.size());
    }
}
```

### Count Result

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

### Sub-Query

To mock a sub-query we need to use deserialization mechanism. There are two approaches, using JSON string or Serialization/Deserialization.
Then after deserialization to desired SObjectType, pass the data to SOQL by calling `.setMock` method.


_Using JSON String_

By passing simple String, it is possible to write non-writable fields, like `Name` on Contact object.

```
@IsTest
static void getAccountsWithContacts() {
    List<Account> mocks = (List<Account>) JSON.deserialize(
        '[{ "Name": "Account Name", "Contacts": { "totalSize": 1, "done": true, "records": [{ "Name": "Contact Name", "Email": "contact.email@address.com" }] }  }],
        List<Account>.class
    );

    List<Account> accounts;

    Test.startTest();
    SOQL.setMock('AccountsController.getAccountsWithContacts', mocks);
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

    List<Account> accounts;

    Test.startTest();
    SOQL.setMock('AccountsController.getAccountsWithContacts', mocks);
    accounts = AccountsController.getAccountsWithContacts();
    Test.stopTest();

    Assert.isNotNull(accounts);
    Assert.isNotNull(accounts[0].contacts);
    Assert.areEqual(1, accounts[0].contacts.size());
}
```
