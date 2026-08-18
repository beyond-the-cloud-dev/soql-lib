---
sidebar_position: 25
---

# MOCKING

Mock SOQLCache results in Unit Tests.

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## Single Record

Set the mocking ID in the query declaration.

```apex title="Controller with Mock ID"
public with sharing class ExampleController {
    public static Account getAccountByName(String accountName) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity)
            .whereEqual(Account.Name, accountName)
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Pass a single SObject record to the SOQLCache class, and use the mock ID to target the query to be mocked.

```apex title="Unit Test with Single Record Mock"
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQLCache.mock('ExampleController.getAccountByName')
            .thenReturn(new Account(Name = TEST_ACCOUNT_NAME));

        Test.startTest();
        Account result = ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.areEqual(TEST_ACCOUNT_NAME, result.Name);
    }
}
```

During execution, SOQLCache will return the record that was set by the `.thenReturn` method.

## Mock by SObjectType

You can also mock cached queries by SObjectType, which is useful when you want to mock all cache queries for a specific object type.

```apex title="Controller without Mock ID"
public with sharing class ExampleController {
    public static Account getAccountData(Id accountId) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .whereEqual(Account.Id, accountId)
            .toObject();
    }
}
```

Use `SOQLCache.mock(SObjectType)` to mock all cached queries for that SObjectType.

```apex title="Unit Test with SObjectType Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountData() {
        Account mockAccount = new Account(
            Id = '001000000000001',
            Name = 'Mock Account',
            BillingCity = 'San Francisco'
        );

        SOQLCache.mock(Account.SObjectType)
            .thenReturn(mockAccount);

        Test.startTest();
        Account result = ExampleController.getAccountData('001000000000001');
        Test.stopTest();

        Assert.areEqual('Mock Account', result.Name);
        Assert.areEqual('San Francisco', result.BillingCity);
    }
}
```

## No Results

```apex title="Controller for No Results Example"
public with sharing class ExampleController {
    public static Account getAccountByName(String accountName) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity)
            .whereEqual(Account.Name, accountName)
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Pass `null` to the `.thenReturn()` method. When `.toObject()` is invoked, it will return `null`, which mimics that the record was not found in the database. SOQL Lib automatically handles `System.QueryException: List has no rows for assignment to SObject` and returns null, so to mimic that behavior use `null` to mock no results.

This behavior will be the same as it is during runtime.

```apex title="Unit Test with Empty List Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountByName_NoResults() {
        SOQLCache.mock('ExampleController.getAccountByName')
            .thenReturn(null); // Empty record

        Test.startTest();
        Account result = ExampleController.getAccountByName('MyAccount 1');
        Test.stopTest();

        Assert.isNull(result);
    }
}
```

## Parent Relationship

Set the mocking ID in the query declaration for queries with parent relationships.

```apex title="Controller with Parent Relationship Query"
public with sharing class ExampleController {
    public static Account getAccountWithOwnerInfo(Id accountId) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .with('Owner', User.Name, User.Email)
            .with('Owner.Profile', Profile.Name)
            .whereEqual(Account.Id, accountId)
            .mockId('ExampleController.getAccountWithOwnerInfo')
            .toObject();
    }
}
```

Create mock data with the parent relationship structure.

```apex title="Unit Test with Parent Relationship Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountWithOwnerInfo() {
        Account mockAccount = new Account(
            Id = '001000000000001',
            Name = 'Test Account',
            Owner = new User(
                Id = '005000000000001',
                Name = 'John Doe',
                Email = 'john.doe@company.com',
                Profile = new Profile(
                    Name = 'System Administrator'
                )
            )
        );

        SOQLCache.mock('ExampleController.getAccountWithOwnerInfo')
            .thenReturn(mockAccount);

        Test.startTest();
        Account result = ExampleController.getAccountWithOwnerInfo('001000000000001');
        Test.stopTest();

        Assert.isNotNull(result);
        Assert.areEqual('Test Account', result.Name);
        Assert.areEqual('John Doe', result.Owner.Name);
        Assert.areEqual('john.doe@company.com', result.Owner.Email);
        Assert.areEqual('System Administrator', result.Owner.Profile.Name);
    }
}
```

## With Static Resource

Set the mocking ID in the query declaration.

```apex title="Controller with Static Resource Query"
public with sharing class ExampleController {
    public static Account getAccountsByIndustry(String industry) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.Industry)
            .whereEqual(Account.Industry, industry)
            .allowFilteringByNonUniqueFields()
            .mockId('ExampleController.getAccountsByIndustry')
            .toObject();
    }
}
```

Pass records from a Static Resource to the SOQLCache class, and use the mock ID to target the query to be mocked.

```apex title="Unit Test with Static Resource Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountsByIndustry() {
        Account mockAccount = (Account) Test.loadData(Account.SObjectType, 'TestAccounts')[0];

        SOQLCache.mock('ExampleController.getAccountsByIndustry')
            .thenReturn(mockAccount);

        Test.startTest();
        Account result = ExampleController.getAccountsByIndustry('Technology');
        Test.stopTest();

        Assert.isNotNull(result);
    }
}
```

During execution, SOQLCache will return records from the Static Resource that were set by the `.thenReturn` method.

## SObjectType Mock with Static Resource

You can also combine SObjectType mocking with Static Resources for broader test coverage.

```apex title="Controller without Mock ID using Static Resource"
public with sharing class ExampleController {
    public static Account getCachedAccountData(String name) {
        return (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Name, Account.Industry, Account.Type)
            .whereEqual(Account.Name, name)
            .toObject();
    }
}
```

```apex title="Unit Test with SObjectType and Static Resource Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getCachedAccountData() {
        List<Account> testAccounts = Test.loadData(Account.SObjectType, 'TestAccounts');
        
        SOQLCache.mock(Account.SObjectType)
            .thenReturn(testAccounts[0]);

        Test.startTest();
        Account result = ExampleController.getCachedAccountData('Test Account');
        Test.stopTest();

        Assert.isNotNull(result);
        Assert.areEqual(testAccounts[0].Name, result.Name);
    }
}
```