---
sidebar_position: 20
---

# MOCKING

Mock SOQLEvaluator results in Unit Tests.

## Single Record

Set mocking ID in Query declaration.

```apex title="Controller with SOQLEvaluator Mock ID"
public with sharing class ExampleController {
    public static Account getAccountFromCollection(String accountName) {
        return (Account) SOQLEvaluator.of([
            SELECT Id, Name, Industry 
            FROM Account 
            WHERE Name LIKE :accountName
            WITH USER_MODE
        ])
        .mockId('ExampleController.getAccountFromCollection')
        .toObject();
    }
}
```

Pass single SObject record to SOQLEvaluator class, and use mock ID to target evaluation to be mocked.

```apex title="Unit Test with Single Record Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountFromCollection() {
        SOQLEvaluator.mock('ExampleController.getAccountFromCollection')
            .thenReturn(new Account(Name = 'MyAccount 1'));

        Test.startTest();
        Account result = ExampleController.getAccountFromCollection('MyAccount 1');
        Test.stopTest();

        Assert.areEqual('MyAccount 1', result.Name);
    }
}
```

During execution SOQLEvaluator will return record that was set by `.thenReturn` method.

## Multiple Records

Set mocking ID in Query declaration.

```apex title="Controller with Multiple Records Processing"
public with sharing class ExampleController {
    public static List<Account> getAccountsFromCollection(String industry) {
        return SOQLEvaluator.of([
            SELECT Id, Name, Industry 
            FROM Account 
            WHERE Industry = :industry
            WITH USER_MODE
        ])
        .mockId('ExampleController.getAccountsFromCollection')
        .toList();
    }
}
```

Pass List of SObject records to SOQLEvaluator class, and use mock ID to target evaluation to be mocked.

```apex title="Unit Test with Multiple Records Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountsFromCollection() {
        List<Account> mockedAccounts = new List<Account>{
            new Account(Name = 'MyAccount 1', Industry = 'Technology'),
            new Account(Name = 'MyAccount 2', Industry = 'Technology')
        };

        SOQLEvaluator.mock('ExampleController.getAccountsFromCollection')
            .thenReturn(mockedAccounts);

        Test.startTest();
        List<Account> result = ExampleController.getAccountsFromCollection('Technology');
        Test.stopTest();

        Assert.areEqual(mockedAccounts, result);
        Assert.areEqual(2, result.size());
    }
}
```

During execution SOQLEvaluator will return List of records that was set by `.thenReturn` method.

## No Results

```apex title="Controller for No Results Example"
public with sharing class ExampleController {
    public static Account getAccountFromCollection(String accountName) {
        return (Account) SOQLEvaluator.of([
            SELECT Id, Name, Industry 
            FROM Account 
            WHERE Name LIKE :accountName
            WITH USER_MODE
        ])
        .mockId('ExampleController.getAccountFromCollection')
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
    @IsTest
    static void getAccountFromCollection_NoResults() {
        SOQLEvaluator.mock('ExampleController.getAccountFromCollection')
            .thenReturn(new List<Account>());

        Test.startTest();
        Account result = ExampleController.getAccountFromCollection('MyAccount 1');
        Test.stopTest();

        Assert.isNull(result);
    }
}
```

## Data Processing with Static Resource

Set mocking ID in Query declaration.

```apex title="Controller with Static Resource Processing"
public with sharing class ExampleController {
    public static List<Account> processAccountCollection(String industry) {
        return SOQLEvaluator.of([
            SELECT Id, Name, Industry, Type 
            FROM Account 
            WHERE Industry = :industry
            WITH USER_MODE
        ])
        .mockId('ExampleController.processAccountCollection')
        .toList();
    }
}
```

Pass records from Static Resource to SOQLEvaluator class, and use mock ID to target evaluation to be mocked.

```apex title="Unit Test with Static Resource Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void processAccountCollection() {
        SOQLEvaluator.mock('ExampleController.processAccountCollection')
            .thenReturn(Test.loadData(Account.SObjectType, 'MyTestAccounts'));

        Test.startTest();
        List<Account> result = ExampleController.processAccountCollection('Technology');
        Test.stopTest();

        Assert.isNotNull(result);
        Assert.isTrue(result.size() > 0);
    }
}
```

During execution SOQLEvaluator will return records from Static Resource that was set by `.thenReturn` method.