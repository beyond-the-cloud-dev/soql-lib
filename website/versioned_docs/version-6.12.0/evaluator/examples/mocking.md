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

## Mock by SObjectType

You can also mock evaluations by SObjectType, which is useful when you want to mock all evaluations for a specific object type.

```apex title="Controller without Mock ID"
public with sharing class ExampleController {
    public static List<Account> processAccountData() {
        return SOQLEvaluator.of([
            SELECT Id, Name, Industry
            FROM Account
            WHERE Industry = 'Technology'
            WITH USER_MODE
        ])
        .toList();
    }
}
```

Use `SOQLEvaluator.mock(SObjectType)` to mock all evaluations for that SObjectType.

```apex title="Unit Test with SObjectType Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void processAccountData() {
        List<Account> mockAccounts = new List<Account>{
            new Account(Name = 'Tech Account 1', Industry = 'Technology'),
            new Account(Name = 'Tech Account 2', Industry = 'Technology')
        };

        SOQLEvaluator.mock(Account.SObjectType)
            .thenReturn(mockAccounts);

        Test.startTest();
        List<Account> result = ExampleController.processAccountData();
        Test.stopTest();

        Assert.areEqual(2, result.size());
        Assert.areEqual('Tech Account 1', result[0].Name);
        Assert.areEqual('Tech Account 2', result[1].Name);
    }
}
```

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

## Sub-Query

Set mocking ID in Query declaration for queries with subqueries.

```apex title="Controller with Sub-Query Processing"
public with sharing class ExampleController {
    public static List<Account> getAccountsWithContacts() {
        return SOQLEvaluator.of([
            SELECT Id, Name, 
                (SELECT Id, Name, Email FROM Contacts)
            FROM Account 
            WHERE Name LIKE 'ACME%'
            WITH USER_MODE
        ])
        .mockId('ExampleController.getAccountsWithContacts')
        .toList();
    }
}
```

Deserialize desired data from JSON format to selected SObjectType and pass data as list of records.

```apex title="Unit Test with JSON Deserialized Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountsWithContacts() {
        List<Account> mocks = (List<Account>) JSON.deserialize(
            '[{ "Name": "ACME Corp", "Contacts": { "totalSize": 1, "done": true, "records": [{ "Name": "John Doe", "Email": "john.doe@acme.com" }] }}]',
            List<Account>.class
        );

        SOQLEvaluator.mock('ExampleController.getAccountsWithContacts')
            .thenReturn(mocks);

        Test.startTest();
        List<Account> result = ExampleController.getAccountsWithContacts();
        Test.stopTest();

        Assert.isNotNull(result);
        Assert.isNotNull(result[0].Contacts);
        Assert.areEqual(1, result[0].Contacts.size());
        Assert.areEqual('John Doe', result[0].Contacts[0].Name);
    }
}
```

Or create data with Test Data Factory and Serialize/Deserialize it to use as a Mock.

```apex title="Unit Test with Serialized Data Mock"
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccountsWithContacts_WithFactory() {
        List<Account> mocks = (List<Account>) JSON.deserialize(
            JSON.serialize(
                new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'Name' => 'ACME Corp',
                        'Contacts' => new Map<String, Object>{
                            'totalSize' => 2,
                            'done' => true,
                            'records' => new List<Contact>{ 
                                new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@acme.com'),
                                new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@acme.com')
                            }
                        }
                    }
                }
            ),
            List<Account>.class
        );

        SOQLEvaluator.mock('ExampleController.getAccountsWithContacts')
            .thenReturn(mocks);

        Test.startTest();
        List<Account> result = ExampleController.getAccountsWithContacts();
        Test.stopTest();

        Assert.isNotNull(result);
        Assert.isNotNull(result[0].Contacts);
        Assert.areEqual(2, result[0].Contacts.size());
    }
}
```

## Parent Relationship

Set mocking ID in Query declaration for queries with parent relationships.

```apex title="Controller with Parent Relationship Processing"
public with sharing class ExampleController {
    public static Account getAccountWithOwnerInfo(Id accountId) {
        return (Account) SOQLEvaluator.of([
            SELECT Id, Name, Owner.Name, Owner.Email, Owner.Profile.Name
            FROM Account 
            WHERE Id = :accountId
            WITH USER_MODE
        ])
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

        SOQLEvaluator.mock('ExampleController.getAccountWithOwnerInfo')
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