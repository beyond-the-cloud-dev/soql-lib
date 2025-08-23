---
sidebar_position: 10
---

# Getting Started

The SOQL Evaluator module was created for developers who don't want to learn a new framework but would like to have some benefits like **mocking** and **enhanced result methods**.

:::info[SOQL Module Recommended]
We recommend using the **SOQL module** instead, as it provides significantly more benefits including query building, caching, field-level security, and sharing controls. However, SOQL Evaluator can still be a valid choice for developers who prefer to stick with traditional SOQL queries while gaining some additional functionality.
:::

## Basic Processing

SOQL Evaluator processes static query `List<SObject>` records.

```apex
// Process query results with enhanced methods
Set<Id> accountIds = SOQLEvaluator.of([SELECT Id FROM Account]).toIds();
String accountName = (String) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toValueOf(Account.Name);
Boolean hasAccounts = SOQLEvaluator.of([SELECT Id FROM Account]).doExist();
```

## Mocking for Tests

One of the main benefits is simplified mocking in unit tests:

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public static Set<Id> getAccountIds(String industry) {
        return SOQLEvaluator.of([SELECT Id FROM Account WHERE Industry = :industry])
            .mockId('ExampleController.getAccountIds')
            .toIds();
    }
}
```

```apex title="Test Implementation"
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
```
