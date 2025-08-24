---
sidebar_position: 25
---

# MOCKING

Mock SOQLCache results in Unit Tests.

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## Single Record

Set mocking ID in Query declaration.

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

Pass single SObject record to SOQLCache class, and use mock ID to target query to be mocked.

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

During execution SOQLCache will return record that was set by `.thenReturn` method.

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

Pass an empty list: `.thenReturn(new List<Type>())`;
- When `.toObject()` is invoked, it will return `null`.

This behavior will be the same as it is during runtime.

```apex title="Unit Test with Empty List Mock"
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName_NoResults() {
        SOQLCache.mock('ExampleController.getAccountByName')
            .thenReturn(new Account()); // Empty record

        Test.startTest();
        Account result = ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.isNull(result?.Name);
    }
}
```

## Parent Relationship

Set mocking ID in Query declaration for queries with parent relationships.

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

Create mock data with parent relationship structure.

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

Set mocking ID in Query declaration.

```apex title="Controller with Static Resource Query"
public with sharing class ExampleController {
    public static List<Account> getAccountsByIndustry(String industry) {
        return SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.Industry)
            .whereEqual(Account.Industry, industry)
            .allowFilteringByNonUniqueFields()
            .mockId('ExampleController.getAccountsByIndustry')
            .toObject();
    }
}
```

Pass records from Static Resource to SOQLCache class, and use mock ID to target query to be mocked.

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

During execution SOQLCache will return records from Static Resource that was set by `.thenReturn` method.
