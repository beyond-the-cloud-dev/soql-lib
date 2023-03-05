# Query Selector (QS) - Query Builder (QB)

Apex QS provides functional constructs for SOQL.

## Examples

```java
public inherited sharing class QS_Account extends SObjectSelector {
    public sObjectType fromSObject() {
        return Account.sObjectType;
    }

    public void globalQueryConfig() {
        selector.fields(new List<sObjectField>{
            Account.Name,
            Account.AccountNumber
        });
    }

    public Account getById(Id accountId) {
        return (Account) selector
            .fields(new List<sObjectField>{
                Account.BillingCity,
                Account.BillingCountry,
                Account.BillingCountryCode
            })
            .whereAre(QS.ConditionGroup
                .add(QS.Condition.field(Account.Id).equal(accountId))
            )
            .preview()
            .asObject();
    }

    public List<Account> getByIds(List<Id> accountIds) {
        return (List<Account>) selector
            .fields(new List<sObjectField>{
                Account.BillingPostalCode,
                Account.BillingState
            })
            .whereAre(QS.ConditionGroup
                .add(QS.Condition.field(Account.Id).inCollection(accountIds))
            )
            .preview()
            .asList();
    }
}
```

## Architecture

![image](README.svg)

### Test Mocking

```java
public class MyController {

    @AuraEnabled
    public static List<Account> getAccounts() {
        return QS_Account()
            .fields(new List<sObjectField>{ Account.Id, Account.Name})
            .setLimit(100)
            .mocking('MyController.getAccounts')
            .toList();
    }
}
```

```java
public class AccountMock implements QB_Mock {
    public List<SObject> records() {
        return new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };
    }
}

@isTest
public class MyControllerTest {

    @isTest
    static void getAccounts() {
        Test.startTest();
        QS_TestMock.setMock('MyController.getAccounts', new AccountMock());

        List<Account> accounts = MyController.getAccounts();
        Test.stopTest();

        Assert.areEqual(accountsToMock.size(), accounts.size(), 'Size should be the same.');
    }
}
```

## Usage

```java
public class MyController {

    // Inline SOQL
    @AuraEnabled
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account;
    }

    // Selector
    @AuraEnabled
    public static List<Account> getAccounts() {
        return new QS_Account().getAll();
    }
}
```
## Benefits

### Separation of Concerns

> Separating the various concerns into different systems or layers makes code easier to navigate and maintain. When changes are made, the impacts and regressions on other areas are minimized, and a healthier and more adaptable program evolves. ~ Salesforce
### SOQL Errors handling

No *List has no rows for assignment to SObject* error. When record not found value will be set to null.

```java
Contact myContact = [SELECT Id, Name FROM Contact WHERE Name = 'invalidName'];
// Error: List has no rows for assignment to SObject

Contact myContact = new QS_Contact()
            .fields(new List<sObjectField>{ Contact.Id, Contact.Name })
            .condition(new QB_Condition(Contact.Name).equal('invalidName'))
            .toObject();
// null
```

### Easy to debug

`Query Debugger` metadata allows to debug SOQL and see results on production without changes in code.

### Test Data Mocking

Selectors provide easy way to mock the data. Speed up your Unit Tests.
External Object cannot be insert during the test, the only way is to mock the result.
### One place to manage all SOQLs

### Modify SOQL on fly

Pass `QB` instance between classes and methods. Add necessary conditions, use builder methods.

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
