---
sidebar_position: 1
slug: '/'
---

# Query Selector (QS) - Query Builder (QB)

Apex QS provides functional constructs for SOQL.

## Examples

```java
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Name,
                    Account.AccountNumber
                })
                .withSharing()
                .systemMode();
        }
    }

    public static QS getByRecordType(String rtDevName) {
        return Selector.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry,
            Account.BillingCountryCode
        }).whereAre(QS.ConditionsGroup
            .add(QS.Condition.recordTypeDeveloperName().equal(rtDevName))
        );
    }
}
```

```java
public with sharing class ExampleController {


    public static List<Account> getAccountsInlineSoql(List<Id> accountIds) {
        return [
            SELECT Name, AccountNumber, BillingCity, BillingCountry, BillingCountryCode
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    public static List<Account> getAccountsSelector(List<Id> accountIds) {
        return (List<Account>) QS_Account.Selector
            .fields(new List<sObjectField>{
                Account.BillingCity,
                Account.BillingCountry,
                Account.BillingCountryCode
            })
            .whereAre(QS.Condition
                .field(Account.Id).inCollection(accountIds)
            )
            .asList();
    }
}
```

## Guidelines

1. Selector class should be small and contains only selector base configuration + very generic methods. Selector should allow building SOQL inline in the place of usage.

We should avoid constructions like that:

```java
public with sharing AccountSelector extends fflib_SObjectSelector {
   public Schema.SObjectType getSObjectType(){
      return Account.sObjectType;
   }

   public override List<Schema.SObjectField> getSObjectFieldList(){
      return new List<Schema.SObjectField> {
         Account.Id,
         Account.Name
      };
   }

   public List<Account> selectById(Set<Id> recordIds){
      fflib_QueryFactory query = newQueryFactory();

      fflib_SObjectSelector addressesSelector = new AddressesSelector();
      addressesSelector.configureQueryFactoryFields(query, 'InvoiceAddress__r');

      return (List<Account>) Database.query( query.toSOQL() );
   }

   // 500 more lines here
}
```

2. Developers should be able to modify SOQL with fields, conditions, and other clauses as needed.
3. Developers should not spend too much time on selector methods naming convention.
- How to name a method with 3 conditions? selectBySomethingAAndSomethingBAndSomehtingC?
- What if an order should be passed as an argument?

```java
public with sharing AccountSelector extends fflib_SObjectSelector {
   public Schema.SObjectType getSObjectType(){
      return Account.sObjectType;
   }

   public override List<Schema.SObjectField> getSObjectFieldList(){
      return new List<Schema.SObjectField> {
         Account.Id,
         Account.Name
      };
   }

   public List<Account> selectById(Set<Id> recordIds){
      fflib_QueryFactory query = newQueryFactory();

      fflib_SObjectSelector addressesSelector = new AddressesSelector();
      addressesSelector.configureQueryFactoryFields(query, 'InvoiceAddress__r');

      return (List<Account>) Database.query( query.toSOQL() );
   }

   // selectBySomethingElse
   // selectBySomethingElseAndMore
   // selectBySomethingElseButWithLimit
}
```

4. Avoid methods where the only difference is a list of fields, limit, order, etc.
5. Selector framework should allow controlling FLS and sharing.
- If fflib_SObjectSelector is marked as `with sharing` it is applied to all methods. However, there are some cases where some methods should be `without sharing`? What we can do? A new selector, but `without sharing`? Not good enough.
6. Selector framework should be able to do dynamic binding without constructions as below:

```
public List<Account> selectByName(Set<String> names){
    fflib_QueryFactory query = newQueryFactory();
    query.setCondition('Name IN :names');
    return (List<Account>) Database.query( query.toSOQL() );
}
```

7. Selector framework should allow for mocking in unit tests.
8. Selector framework should allow building query/adjust on the fly.

## Architecture

![image](assets/Architecture.png)

### SELECT fields, Parent.Field FROM SObject

```java
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            // default fields
            return QS.of(QS_Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return (List<Account>) QS_Account.Selector
            .fields(new List<sObjectField>{
                Account.BillingCity,
                Account.BillingState,
                Account.BillingStreet,
                Account.BillingCountry
            }).asList();
    }

    public static List<Account> getAccountsWithCreatedBy() {
        return (List<Account>) QS_Account.Selector
            .relatedFields('CreatedBy', new List<sObjectField>{
                User.Id,
                User.Name
            }).asList();
    }
}
```

### SELECT Count(), Count(Field) alias FROM SObject

```java
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType);
        }
    }
}

public with sharing class MyController {

    public static Integer getAccountAmount() {
        return QS_Account.Selector.count().asInteger();
    }

    public static Integer getUniqueAccountNameAmount() {
        return QS_Account.Selector.countAs(Account.Name, 'names').asAggregated()[0].names;
    }
}
```

### SELECT fields, (SELECT fields FROM ChildSObject) FROM SObject

```java
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(QS_Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return (List<Account>) QS_Account.Selector
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id,
                    Contact.Name
                })
            ).asList();
    }
}
```

### SELECT fields FROM SObject USING SCOPE scope

```java
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(QS_Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getMineAccounts() {
        return (List<Account>) QS_Account.Selector
            .mineScope()
            .asList();
    }

    public static List<Account> getTeamAccounts() {
        return (List<Account>) QS_Account.Selector
            .myTeamScope()
            .asList();
    }
}
```

### TBD

```java
public inherited sharing class QS_YourObject {

    public static QS Selector {
        get {
            return QS.of(YourObject.sObjectType)
                // Where
                .whereAre(QS.ConditionsGroup
                    .add(QS.Condition.field(YourObject.FieldA).equal('Value 1'))
                    .add(QS.Condition.field(YourObject.FieldA).equal('Value 2'))
                    .order('1 OR 2')
                )
                // Group By
                .groupBy(YourObject.FieldE)
                .groupByRollup(YourObject.FieldE)
                .groupByCube(YourObject.FieldE)
                // Order By
                .orderBy(YourObject.FieldF)
                .orderByRelated('ParentRelationshipName', YourParentObject.FieldG)
                .sortAsc()
                .sortDesc()
                .nullsFirst()
                .nullsLast()
                // Limit
                .setLimit(50000)
                // Offset
                .setOffset(2000)
                // For
                .forReference()
                .forView()
                .forUpate()
                .allRows()
                // FLS - USER_MODE by default
                .systemMode()
                // Sharing - Inherited sharing by default
                .withSharing()
                .withoutSharing()
                // Mocking
                .mocking('queryIdentifier')
                // Debug
                .preview()
                // Result
                .asObject()
                .asList()
                .asInteger()
                // Generic methods
                .getById(recordId)
                .getByIds(recordIds);
        }
    }
}
```

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
