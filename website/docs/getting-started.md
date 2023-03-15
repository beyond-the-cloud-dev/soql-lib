---
sidebar_position: 1
slug: '/'
---

# Getting started

Apex QS provides functional constructs for SOQL.

## Examples

```apex
//SELECT Id FROM Account
List<Account> accounts = (List<Account>) QS.of(Account.sObjectType).asList();
```

```apex
//SELECT Id, Name, Industry, Country FROM Account
List<Account> accounts = (List<Account>) QS.of(Account.sObjectType)
   .fields(new List<sObjectField>{
      Account.Id, Account.Name, Account.Industry, Account.Country
   })
   .asList();
```

## Guidelines

1. Selector class should be small and contains only selector base configuration + very generic methods.

   We should avoid constructions like that:

   ```apex
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
2. Selector should allows building SOQL inline in the place of usage, however default configuration should be provided by selector class `QS_Account`.
   ```apex
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
   }
   ```
3. Developers should be able to modify SOQL with fields, conditions, and other clauses as needed.
4. Developers should not spend time on selector methods naming convention.
   - How to name a method with 3 conditions? selectBySomethingAAndSomethingBAndSomehtingC?
   - What if an order should be passed as an argument?

   ```apex
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

5. Avoid methods where the only difference is a list of fields, limit, order, etc.
6. Selector framework should allow controlling FLS and sharing. If fflib_SObjectSelector is marked as `with sharing` it is applied to all methods. However, there are some cases where some methods should be `without sharing`? What we can do? A new selector, but `without sharing`? Not good enough.
7. Selector framework should be able to do dynamic binding without constructions as below:

   ```apex
   public List<Account> selectByName(Set<String> names){
      fflib_QueryFactory query = newQueryFactory();
      query.setCondition('Name IN :names');
      return (List<Account>) Database.query( query.toSOQL() );
   }
   ```

8. Selector framework should allow for mocking in unit tests.
9. Selector framework should allow building query/adjust on the fly.

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
