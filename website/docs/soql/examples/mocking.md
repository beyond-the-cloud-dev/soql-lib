---
sidebar_position: 130
---

# MOCKING

Mock SOQL results in Unit Tests.

You need to mock external objects.

> In Apex tests, use dynamic SOQL to query external objects. Tests that perform static SOQL queries of external objects fail. ~ Salesforce

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## Single Record

Set mocking ID in Query declaration.

```apex title="Controller with Mock ID"
public with sharing class ExampleController {
    public static Account getAccountByName(String accountName) {
        return (Account) SOQL.of(Account.SObjectType)
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Pass single SObject record to SOQL class, and use mock ID to target query to be mocked.

```apex title="Unit Test with Single Record Mock"
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQL.mock('ExampleController.getAccountByName')
            .thenReturn(new Account(Name = TEST_ACCOUNT_NAME));

        Test.startTest();
        Account result = (Account) ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.areEqual(TEST_ACCOUNT_NAME, result.Name);
    }
}
```

During execution Selector will return record that was set by `.thenReturn` method.


## AggregateResult

To mock `AggregateResult` - use `toAggregatedProxy()`.

```apex title="Controller with Aggregate Query Mock"
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

```apex title="Unit Test with Aggregate Result Mock"
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

```apex title="Controller for No Results Example"
public with sharing class ExampleController {
    public static Account getAccountByName(String accountName) {
        return (Account) SOQL.of(Account.SObjectType)
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Pass an empty list: `.thenReturn(new List<Type>())`;
- When `.toList()` is invoked, it will return a `List<Type>`.
- When `.toObject()` is invoked, it will return `null`.

This behavior will be the same as it is during runtime.

```apex title="Unit Test with Empty List Mock"
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

## Multiple Records

Set mocking ID in Query declaration.

```apex title="Controller with Multiple Records Query"
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL.of(Account.SObjectType)
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

```apex title="Unit Test with Multiple Records Mock"
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.mock('ExampleController.getPartnerAccounts')
            .thenReturn(accounts);

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.areEqual(accounts, result);
    }
}
```

During execution Selector will return List of records that was set by `.thenReturn` method.

## Count Result

Set mocking ID in Query declaration.

```apex title="Controller with Count Query"
public with sharing class ExampleController {

    public static List<Account> getPartnerAccountsCount(String accountName) {
        return SOQL.of(Account.SObjectType)
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

```apex title="Unit Test with Count Mock"
@IsTest
public class ExampleControllerTest {
    private static final Integer TEST_VALUE = 5;

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.mock('ExampleController.getPartnerAccountsCount')
            .thenReturn(TEST_VALUE);

        Test.startTest();
        Integer result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.areEqual(TEST_VALUE, result);
    }
}
```

During execution Selector will return Integer count that was set by `.thenReturn` method.

## With Static Resource

Set mocking ID in Query declaration.

```apex title="Controller with Static Resource Mock"
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL.of(Account.SObjectType)
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

```apex title="Unit Test with Static Resource Mock"
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.mock('ExampleController.getPartnerAccounts')
            .thenReturn(Test.loadData(Account.SObjectType, 'MyAccounts'));

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.isNotNull(result);
    }
}
```

During execution Selector will return records from Static Resource that was set by `.thenReturn` method.

## Sub-Query

Set mocking ID in Query declaration.

```apex title="Controller with Sub-Query Mock"
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

```apex title="Unit Test with JSON Deserialized Mock"
@IsTest
static void getAccountsWithContacts() {
    List<Account> mocks = (List<Account>) JSON.deserialize(
        '[{ "Name": "Account Name", "Contacts": { "totalSize": 1, "done": true, "records": [{ "Name": "Contact Name", "Email": "contact.email@address.com" }] }  }],
        List<Account>.class
    );

    SOQL.mock('AccountsController.getAccountsWithContacts')
        .thenReturn(mocks);

    List<Account> accounts;

    Test.startTest();
    accounts = AccountsController.getAccountsWithContacts();
    Test.stopTest();

    Assert.isNotNull(accounts);
    Assert.isNotNull(accounts[0].contacts);
    Assert.areEqual(1, accounts[0].contacts.size());
}
```

Or create data with Test Data Factory and Serialize/Deserialize it to use as a Mock.

```apex title="Unit Test with Serialized Data Mock"
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

    SOQL.mock('AccountsController.getAccountsWithContacts')
        .thenReturn(mocks);

    List<Account> accounts;

    Test.startTest();
    accounts = AccountsController.getAccountsWithContacts();
    Test.stopTest();

    Assert.isNotNull(accounts);
    Assert.isNotNull(accounts[0].contacts);
    Assert.areEqual(1, accounts[0].contacts.size());
}
```

During execution Selector will ignore filters and return data set by a mock.

## Parent Relationship

```apex title="Unit Test with Parent Relationship Mock"
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