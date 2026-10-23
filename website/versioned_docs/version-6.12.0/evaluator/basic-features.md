---
sidebar_position: 15
---

# Basic Features

## Processing Static Query Results

SOQLEvaluator processes static query `List<SObject>` collections. It provides enhanced result transformation methods while keeping your traditional SOQL syntax.

```apex title="Direct Query Processing"
// Process query results directly
Set<Id> contactIds = SOQLEvaluator.of([SELECT Id, AccountId FROM Contact]).toIds();
Set<Id> accountIds = SOQLEvaluator.of([SELECT Id, AccountId FROM Contact]).toIdsOf(Contact.AccountId);
```

## Field-Level Security

SOQLEvaluator can apply field-level security to existing records using the `stripInaccessible()` method, which removes fields the current user cannot access.

```apex title="Default FLS Processing"
// Apply FLS with default AccessType.READABLE
Task processedTask = (Task) SOQLEvaluator.of([
        SELECT Id, Subject, Type 
        FROM Task 
        WITH SYSTEM_MODE
    ])
    .stripInaccessible()
    .toObject();
```

```apex title="Custom AccessType"
// Specify AccessType explicitly
List<Task> processedTasks = SOQLEvaluator.of([SELECT Id, Subject, Type FROM Task WITH SYSTEM_MODE])
    .stripInaccessible(AccessType.READABLE)
    .toList();
```

## Mocking for Tests

SOQLEvaluator supports mocking for unit tests, allowing you to substitute real database results with prepared test data. This is particularly useful when you want to test your result processing logic without depending on actual database records.

**How it works:** Use `.mockId(id)` to identify your evaluator call, then in tests use `SOQLEvaluator.mock(id).thenReturn(data)` to provide test data.

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public static Set<Id> getAccountIds(String industry) {
        return SOQLEvaluator.of([SELECT Id FROM Account WHERE Industry = :industry])
            .mockId('ExampleController.getAccountIds')
            .toIds();
    }

    public static Account getFirstTechAccount() {
        return (Account) SOQLEvaluator.of([SELECT Id, Name, Industry FROM Account WHERE Industry = 'Technology'])
            .mockId('ExampleController.getFirstTechAccount')
            .toObject();
    }
}
```

### Mock List of Records

```apex title="Test - List of Records"
@IsTest
private class ExampleControllerTest {
    @IsTest
    static void testGetAccountIds() {
        // Mock the evaluator results
        SOQLEvaluator.mock('ExampleController.getAccountIds').thenReturn(new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        });

        // Test
        Set<Id> result = ExampleController.getAccountIds('Technology');

        // Verify
        Assert.areEqual(2, result.size(), 'Should return 2 account IDs');
    }
}
```

### Mock Single Record

```apex title="Test - Single Record"
@IsTest
private class ExampleControllerTest {
    @IsTest
    static void testGetFirstTechAccount() {
        // Mock the evaluator result
        SOQLEvaluator.mock('ExampleController.getFirstTechAccount')
            .thenReturn(new Account(Name = 'Mocked Tech Account', Industry = 'Technology'));

        // Test
        Account result = ExampleController.getFirstTechAccount();

        // Verify
        Assert.areEqual('Mocked Tech Account', result.Name);
        Assert.areEqual('Technology', result.Industry);
    }
}
```

## Enhanced Result Methods

SOQLEvaluator provides enhanced result transformation methods to simplify common data operations.
You can use many predefined methods that reduce code complexity and improve readability.

```apex title="Available Result Methods"
Id toId();
Set<Id> toIds();
Set<Id> toIdsOf(SObjectField field);
Set<Id> toIdsOf(String relationshipName, SObjectField field);
Boolean doExist();
Object toValueOf(SObjectField fieldToExtract);
Set<String> toValuesOf(SObjectField fieldToExtract);
SObject toObject();
List<SObject> toList();
Map<Id, SObject> toMap();
Map<String, SObject> toMap(SObjectField keyField);
Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField);
Map<String, String> toMap(SObjectField keyField, SObjectField valueField);
Map<String, List<SObject>> toAggregatedMap(SObjectField keyField);
Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField);
Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField);
```

Extract unique IDs from query:

❌

```apex title="Traditional Approach - Extract IDs"
public static Set<Id> getAccountOwnerIds() {
    Set<Id> ownerIds = new Set<Id>();
    
    for (Account account : [SELECT OwnerId FROM Account]) {
        ownerIds.add(account.OwnerId);
    }
    
    return ownerIds;
}
```

✅

```apex title="SOQLEvaluator Approach - Extract IDs"
public static Set<Id> getAccountOwnerIds() {
    return SOQLEvaluator.of([SELECT OwnerId FROM Account]).toIdsOf(Account.OwnerId);
}
```

Create custom maps:

❌

```apex title="Traditional Approach - Custom Map"
public static Map<Id, Id> getContactIdByAccountId() {
    Map<Id, Id> contactIdToAccountId = new Map<Id, Id>();

    for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
        contactIdToAccountId.put(contact.Id, contact.AccountId);
    }

    return contactIdToAccountId;
}
```

✅

```apex title="SOQLEvaluator Approach - Custom Map"
public static Map<String, String> getContactIdByAccountId() {
    return SOQLEvaluator.of([SELECT Id, AccountId FROM Contact]).toMap(Contact.Id, Contact.AccountId);
}
```

Extract unique values from query:

❌

```apex title="Traditional Approach - Unique Values"
public static Set<String> getAccountNames() {
    Set<String> accountNames = new Set<String>();

    for (Account account : [SELECT Name FROM Account]) {
        accountNames.add(account.Name);
    }

    return accountNames;
}
```

✅

```apex title="SOQLEvaluator Approach - Unique Values"
public static Set<String> getAccountNames() {
    return SOQLEvaluator.of([SELECT Name FROM Account]).toValuesOf(Account.Name);
}
```

Check if records exist:

❌

```apex title="Traditional Approach - Check Existence"
public static Boolean hasActiveContacts() {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE IsActive__c = true LIMIT 1];
    return !contacts.isEmpty();
}
```

✅

```apex title="SOQLEvaluator Approach - Check Existence"
public static Boolean hasActiveContacts() {
    return SOQLEvaluator.of([SELECT Id FROM Contact WHERE IsActive__c = true]).doExist();
}
```

Extract single field value:

❌

```apex title="Traditional Approach - Single Field"
public static String getAccountIndustry(Id accountId) {
    Account account = [SELECT Industry FROM Account WHERE Id = :accountId LIMIT 1];
    return account.Industry;
}
```

✅

```apex title="SOQLEvaluator Approach - Single Field"
public static String getAccountIndustry(Id accountId) {
    return (String) SOQLEvaluator.of([SELECT Industry FROM Account WHERE Id = :accountId])
        .toValueOf(Account.Industry);
}
```

SOQLEvaluator provides a simple way to enhance your existing SOQL-based code with powerful result transformation methods, making your code more concise and readable while maintaining the familiar SOQL syntax you already know.
