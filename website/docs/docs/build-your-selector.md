---
slug: '/building-your-selector'
sidebar_position: 17
---

# Building Your Selector

Check examples in the [repository](https://github.com/beyond-the-cloud-dev/soql-lib/tree/main/force-app/main/default/classes/examples/standard-selectors).


SOQL-Lib is agile, so you can adjust the solution according to your needs.
We don't force one approach over another, you can choose your own. Here are our propositions:

## A - Inheritance - extends SOQL, implements Interface + static (Recommended)

Most Flexible Approach:
- The selector constructor keeps default configurations, such as default fields, sharing mode, and field-level security.
- Only very generic methods are maintained in the selector class, and each method returns an instance of that selector. This approach allows you to chain methods from the selector class.
- Additional fields, more complex conditions, ordering, limits, and other SOQL clauses can be built where they are needed (for example, in a controller method).

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Account byIndustry(String industry) {
        with(Account.Industry)
            .whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        with(Account.ParentId)
            .whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }
}
```

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL_Account.query()
            .byRecordType('Partner')
            .whereAre(SOQL.Filter.name().contains(accountName))
            .with(Account.BillingCity, Account.BillingCountry)
            .toList();
    }

    @AuraEnabled
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query()
            .byIndustry('IT')
            .byRecordType(recordType)
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }
}
```

## B - Composition - implements Interface + static

Use `SOQL.Selector` and create `static` methods.

```apex
public inherited sharing class SOQL_Contact implements SOQL.Selector {
    public static SOQL query() {
        // default settings
        return SOQL.of(Contact.SObjectType)
            .with(Contact.Id, Contact.Name, Contact.AccountId)
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byAccountId(Id accountId) {
        return query()
            .whereAre(SOQL.Filter.with(Contact.AccountId).equal(accountId));
    }

    public static String toName(Id contactId) {
        return (String) query().byId(contactId).toValueOf(Contact.Name);
    }
}
```

```apex
public with sharing class ExampleController {

    @AuraEnabled
    public static List<Contact> getContactsByRecordType(String recordType) {
        return SOQL_Contact.byRecordType(recordType)
            .with(Contact.Email, Contact.Title)
            .toList();
    }

    @AuraEnabled
    public static List<Contact> getContactsRelatedToAccount(Id accountId) {
        return SOQL_Contact.byAccountId(accountId).toList();
    }

    @AuraEnabled
    public static String getContactName(Id contactId) {
        return SOQL_Contact.toName(contactId);
    }
}
```

## C - Inheritance - extends SOQL + non-static

```apex
public inherited sharing class SOQL_Account extends SOQL {
    public SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Account byIndustry(String industry) {
        with(Account.Industry)
            .whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        with(Account.ParentId)
            .whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }

    public String toIndustry(Id accountId) {
        return (String) byId(accountId).toValueOf(Account.Industry);
    }
}
```

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Account> getPartnerAccounts(String accountName) {
        return new SOQL_Account()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .toList();
    }

    @AuraEnabled
    public static List<Account> getAccountsByRecordType(String recordType) {
        return new SOQL_Account()
            .byRecordType(recordType)
            .byIndustry('IT')
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }

    @AuraEnabled
    public static String getAccountIndustry(Id accountId) {
        return new SOQL_Account().toIndustry(accountId);
    }
}
```

## D - Composition - implements Interface + non-static

Very useful when you have different teams/streams that need different query configurations.

```apex
public inherited sharing virtual class BaseAccountSelector implements SOQL.Selector {
    public virtual SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }

    public SOQL byRecordType(String rt) {
        return query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
```

```apex
public with sharing class MyTeam_AccountSelector extends BaseAccountSelector implements SOQL.Selector {
    public override SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.AccountNumber)
            .systemMode()
            .withoutSharing();
    }
}
```

```apex
public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return new MyTeam_AccountSelector().query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return new MyTeam_AccountSelector().byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
```

## E - Custom

Create Selectors in your own way.

```apex
public inherited sharing class SOQL_Account {
    public static SOQL query {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }

    public static SOQL byRecordType(String rt) {
        return query
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
```

```apex
public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return SOQL_Account.query
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
```

## F - FFLib Approach

```apex

public inherited sharing class SOQL_Opportunity extends SOQL {
    public SOQL_Opportunity() {
        super(Opportunity.SObjectType);
        // default settings
        with(Opportunity.Id, Opportunity.AccountId)
        .systemMode()
        .withoutSharing();
    }

    public List<Opportunity> byRecordType(String rt) {
        return whereAre(Filter.recordType().equal(rt)).toList();
    }

    public List<Opportunity> byAccountId(Id accountId) {
        return with(Opportunity.AccountId).whereAre(Filter.with(Opportunity.AccountId).equal(accountId)).toList();
    }

    public Integer toAmount(Id opportunityId) {
        return (Integer) byId(opportunityId).toValueOf(Opportunity.Amount);
    }
}
```
