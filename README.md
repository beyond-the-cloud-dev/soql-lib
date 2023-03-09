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

## Architecture

![image](README.svg)

```java
public inherited sharing class QS_YourObject {

    public static QS Selector {
        get {
            return QS.of(YourObject.sObjectType)
                // Fields
                .count()
                .countAs(YourObject.sObjectField, 'alias')
                .fields(new List<sObjectField>{
                    YourObject.FieldA,
                    YourObject.FieldB
                })
                .relatedFields('ParentRelationshipName', new List<sObjectField>{
                    YourParentObject.FieldA,
                    YourParentObject.FieldB
                })
                // SubQuery
                .subQuery(QS.Sub.of('ChildRelationshipName')
                    .fields(new List<sObjectField>{
                        ChildObject.FieldC,
                        ChildObject.FieldD
                    })
                )
                // Scope
                .delegatedScope()
                .mineScope()
                .mineAndMyGroupsScope()
                .myTerritoryScope()
                .myTeamTerritoryScope()
                .teamScope()
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


## Assumptions

1. Selector class should be not huge and complicated.

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

2. Developer should be able to modify SOQL as needed, with fields, conditions, etc as needed.
3. Developer should not spend to much time of methods naming. e.g. How to name method with 3 conditions? selectBySomethingAAndSomethingBAndSomehtingC?

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

4. Simliar methods where the only differences is list of fields, limit, order, etc should be avoided.
5. Selector framework should allows to controll FLS and sharing.
- If fflib_SObjectSelector is marked as `with sharing` it is applied to all methods. However there are some cases where some methods should be `without sharing`? What we can do? A new selector, but `without sharing`? Not good enough.
6.  Selector framework should be able to do dynamic binding without constructions as below:

```
public List<Account> selectByName(Set<String> names){
    fflib_QueryFactory query = newQueryFactory();
    query.setCondition('Name IN :names');
    return (List<Account>) Database.query( query.toSOQL() );
}
```

New Salesforce feature allows to do it dynamically: [queryWithBinds(queryString, bindMap, accessLevel)](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm#apex_System_Database_queryWithBinds)

7. Selector framwork should allow for mocking.
8. Selector framwork should allow to build query on fly.

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
            .condition(QS.Condition.field(Contact.Name).equal('invalidName'))
            .toObject();
// null
```

### Easy to debug

`.preview()` method allows you to see query in the debug logs with all bind variables.
### Test Data Mocking

Selectors provide easy way to mock the data. Speed up your Unit Tests.
External Object cannot be insert during the test, the only way is to mock the result.
### Modify SOQL on fly

Pass `QB` instance between classes and methods. Add necessary conditions, use builder methods.

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
