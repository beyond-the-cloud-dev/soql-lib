---
sidebar_position: 17
---

# Building Your Selector

:::info[New Selector Approach!]

The concept of selectors in SOQL Lib is different from FFLib Selectors!

:::

## Old Approach

The [FFLib Selector](https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectSelector.cls) concept assumes that all queries should be stored in the selector class.

**Benefits:**
- Avoids query duplication
- Provides one place to manage all queries

**Issues:**
- One-time queries (like aggregation or case-specific queries) get added to selectors
- Huge classes with numerous methods
- Queries become difficult to reuse
- Similar methods with small differences (limit, offset, etc.)
- Challenges with method naming conventions
- Frequent merge conflicts in team environments

## New Approach

SOQL Lib takes a different approach based on real-world project analysis.

**Core Assumption:**

Most SOQL queries in a project are **one-time** queries executed for specific business cases.

**Our Solution:**
1. **Small Selector Classes** - Selector classes should be small and contain ONLY base query configurations (fields, sharing settings) and very generic methods (`byId`, `byRecordType`)
2. **Build SOQL Inline Where Needed** - Business-specific SOQL queries should be built inline using the SOQL builder exactly where they're needed
3. **Eliminate Method Naming Overhead** - Since queries are created inline, there's no need to spend time finding appropriate method names
4. **Preserve Selector Strengths** - Maintain default selector configurations (default fields, sharing settings) and keep generic methods

Check examples in our [repository](https://github.com/beyond-the-cloud-dev/soql-lib/tree/main/examples/main/default/classes/standard-selectors).

SOQL Lib is flexible, allowing you to adjust the solution according to your specific needs.

**We don't enforce one approach over another; you can choose what works best for your team**. 

## A - Inheritance - extends SOQL, implements Interface + static _(Recommended)_

**The Most Flexible Approach:**
- The selector constructor maintains default configurations such as default fields, sharing mode, and field-level security
- Only very generic methods are kept in the selector class, with each method returning an instance of the selector to enable method chaining
- Additional fields, complex conditions, ordering, limits, and other SOQL clauses are built exactly where they're needed (e.g., in controller methods)

```apex title="SOQL_Account.cls"
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
        whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }
}
```

```apex title="ExampleController.cls"
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

This approach uses `SOQL.Selector` interface with `static` methods for query construction.

```apex title="SOQL_Contact.cls"
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

```apex title="ExampleController.cls"
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

```apex title="SOQL_Account.cls"
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

```apex title="ExampleController.cls"
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

This approach is particularly useful when you have different teams or development streams that require different query configurations.

```apex title="BaseAccountSelector.cls"
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

```apex title="MyTeam_AccountSelector.cls"
public with sharing class MyTeam_AccountSelector extends BaseAccountSelector implements SOQL.Selector {
    public override SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.AccountNumber)
            .systemMode()
            .withoutSharing();
    }
}
```

```apex title="ExampleController.cls"
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

Create selectors using your own custom approach and conventions.

```apex title="SOQL_Account.cls"
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

```apex title="ExampleController.cls"
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

## F - Traditional FFLib Approach

This approach follows the traditional FFLib selector pattern for comparison purposes.

```apex title="OpportunitySelector.cls"
public inherited sharing class OpportunitySelector extends SOQL {
    public OpportunitySelector() {
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
