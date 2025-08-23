---
sidebar_position: 25
---

# MOCKING

Mock SOQL results in Unit Tests.

You need to mock external objects.

> In Apex tests, use dynamic SOQL to query external objects. Tests that perform static SOQL queries of external objects fail. ~ Salesforce

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQLCache.of(...)` with `YourCachedSelectorName.query()`.

## Mock Single Record

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {
    public static Account getAccount(Id accountId) {
        return (Account) SOQL.of(Account.SObjectType)
            .with(Account.BillingCity, Account.BillingCountry)
            .byId(accountId)
            .mockId('ExampleController.getAccount')
            .toObject();
    }
}
```

Pass single SObject record to SOQL class, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {
    @IsTest
    static void getAccount() {
        SOQLCache.mock('ExampleController.getAccount')
            .thenReturn(new Account(Name = 'MyAccount 1'));

        Test.startTest();
        Account result = (Account) ExampleController.getAccountByName('MyAccount 1');
        Test.stopTest();

        Assert.areEqual('MyAccount 1', result.Name);
    }
}
```

During execution Selector will return record that was set by `.thenReturn` method.
