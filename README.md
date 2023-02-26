# Query Selector (QS) - Query Builder (QB)

Dynamic SOQL refers to the creation of a SOQL string at run time with Apex code. Dynamic SOQL enables you to create more flexible applications. For example, you can create a search based on input from an end user or update records with varying field names.

## Architecture

Framework has two main classes:
- Query Builder (`QB.cls`) - Builder, that allows you to create and execute dynamic SQOL.
- Query Selector (`QS.cls`) - Extends `QB` and add Selector specific logic, that can be use by concrete selectors.

![image](README.svg)
### Query Builder (QB)

Allows to build and execute dynamic SQOL.

Query Builder (QB) framework uses [Composite](https://refactoring.guru/design-patterns/composite) and [Builder](https://refactoring.guru/design-patterns/builder) patterns.

Each query clause (`SELECT`, `FROM`, `WHERE`, `LIMIT`) is represented by separated Apex Class (Single Responsibility Principle).

| Index | Statement         | Apex Class                                   |
| ----- | ----------------- | -------------------------------------------- |
| 1     | SELECT            | `QB_Fields.cls`                              |
| 2     | subQuery          | `QB_Sub.cls`                                 |
| 3     | FROM              | `QB_From.cls`                                |
| 4     | USING SCOPE       | `QB_Scope.cls`, `QB_SubQueries.cls`          |
| 5     | WHERE             | `QB_ConditionsGroup.cls`, `QB_Condition.cls` |
| 6     | SECURITY_ENFORCED | `QB_WithSecurityEnforced.cls`                |
| 7     | GROUP BY          | `QB_GroupBy.cls`                             |
| 8     | ORDER BY          | `QB_OrderBy.cls`                             |
| 9     | LIMIT             | `QB_Limit.cls`                               |
| 10    | OFFSET            | `QB_Offset.cls`                              |
| 11    | FOR               | `QB_For.cls`                                 |


All classes mentioned above and `QB.cls` extends `QB_QueryClause.clss` abstract class.

```java
public abstract class QB_QueryClause {

    public abstract String build();

    public virtual String validate() {
        return '';
    }
}
```

Classes needs to implement:
- `String build()` - returns SOQL part.
- `String validate()` - can be use to provide additional validation that will be executed during build phase.

Developer should use:
- `QS_ObjectA.cls` - to build SOQL.
- `QB_ConditionsGroup.cls`, `QB_Condition.cls` - to prepare conditions.
- `QB_TestMock.cls`, `QB_Mock.cls` - to mock query results in unit tests.

```java
new QB(sObjectType)
    // Fields
    .fields(List<sObjectField> fields)
    .fields(String commaSeparatedFields)
    .relationship(String relationshipName, List<sObjectField> fields)
    // SubQuery
    .subQuery(QB_Sub subQueryBuilder)
    // Scope - only one
    .delegatedScope()
    .mineScope()
    .mineAndMyGroupsScope()
    .myTerritoryScope()
    .myTeamTerritoryScope()
    .teamScope()
    // Where
    .condition(QB_ConditionClause conditionClause)
    .conditionsOrder(String conditionsOrder)
    // Security
    .withoutSecurityEnforced() // WITH SECURITY ENFORCED by default
    .withSharing()
    .withoutSharing()
    // Group By
    .groupBy(sObjectField field)
    .groupBy(List<sObjectField> fields)
    // Order By
    .ascOrder(sObjectField field)
    .ascOrder(String field)
    .descOrder(sObjectField field)
    .descOrder(String field)
    .nullFirst()
    .nullLast()
    // Limit
    .setLimit(Integer soqlLimit)
    // Offset
    .setOffset(Integer soqlOffset)
    // For - only one
    .forReference()
    .forView()
    .forUpdate()
    .allRows()
    // Mocking - Allow mocking in unit tests
    .mocking(String queryIdentifier)
    // Debug
    .preview()
    // Execute
    .toSObject()
    .toSObjects()
```

### Query Selector (QS)

Query Builder is middle class between `QB.cls` and concrete selectors.
QS contains default methods that can be used by new selectors.

SObject Selectors should extends `QS` class, and implements the following methods:
- `getById(Id recordId)`
- `getByIds(List<Id> recordIds)`
- `toObject()`
- `toList()`

**NOTE** Methods implementation **CANNOT** be forced by interface/abstract method, because methods return instances of concrete object so developer do not need to cast it.

### Conditions

Conditions are handled by the following classes:
 - `QB_Condition.cls`
 - `QB_ConditionsGroup.cls`

It allows build conditions in dynamic way. Pass `QB_ConditionsGroup` instance between methods and modify it.

```java
new QB_Condition(Schema.SObjectField field)
new QB_Condition(String fieldName)
```

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
        return [SELECT Id, Name FROM Account LIMIT 100];
    }

    // Selector
    @AuraEnabled
    public static List<Account> getAccounts() {
        return QS_Account()
            .fields(new List<sObjectField>{ Account.Id, Account.Name})
            .setLimit(100)
            .toList();
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
