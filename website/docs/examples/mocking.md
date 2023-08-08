---
sidebar_position: 13
---

# MOCKING

Mock SOQL results in Unit Tests.

You need to mock external objects.

> In Apex tests, use dynamic SOQL to query external objects. Tests that perform static SOQL queries of external objects fail. ~ Salesforce

## Mock Single Record

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {

    public static List<Account> getAccountByName(String accountName) {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Pass single SObject record to SOQL class, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQL.setMock('ExampleController.getAccountByName', new Account(Name = TEST_ACCOUNT_NAME));

        Test.startTest();
        Account result = (Account) ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.areEqual(TEST_ACCOUNT_NAME, result.Name);
    }
}
```

During execution Selector will return record that was set by `.setMock` method.

## Mock Multiple Records

Set mocking ID in Query declaration.

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
Pass List of SObject records to SOQL class, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.setMock('ExampleController.getPartnerAccounts', accounts);

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.areEqual(accounts, result);
    }
}
```

During execution Selector will return List of records that was set by `.setMock` method.

## Mock Count Result

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccountsCount(String accountName) {
        return SOQL_Account.query()
            .count()
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccountsCount')
            .toInteger();
    }
}
```
Pass Integer value to SOQL class, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {
    private static final Integer TEST_VALUE = 5;

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.setMock('ExampleController.getPartnerAccountsCount', TEST_VALUE);

        Test.startTest();
        Integer result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.areEqual(TEST_VALUE, result);
    }
}
```

During execution Selector will return Integer count that was set by `.setMock` method.

## Mock with Static Resource

Set mocking ID in Query declaration.

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

Pass String value with name of Static Resource file with `.csv` records, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.setMock('ExampleController.getPartnerAccounts', Test.loadData(Account.SObjectType, 'MyAccounts'));

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.isNotNull(result);
    }
}
```

During execution Selector will return records from Static Resource that was set by `.setMock` method.

## Mock Sub-Query

Set mocking ID in Query declaration.

```
public without sharing class AccountsController {
    public static List<Account> getAccountsWithContacts() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(
                SOQL.SubQuery.of('Contacts')
                    .with(Contact.Id, Contact.Name, Contact.AccountId, Contact.Email)
            )
            .mockId('AccountsController.getAccountsWithContacts')
            .toList();
    }
}
```

Deserialize desired data from JSON format to selected SObjectType. And pass data in form of single record or list of records.

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

Or create data with Test Data Factory and Serialize/Deserialize it to use as a Mock.

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

During execution Selector will ignore filters and return data set by a mock.
