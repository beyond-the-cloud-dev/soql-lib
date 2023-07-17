---
sidebar_position: 2
---

# Overview

## Assumptions

1. **Small Selector Classes** - The selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`byId`, `byRecordType`). Why?
   - Huge classes are hard to manage.
   - A lot of merge conflicts.
   - Problems with methods naming.
2. **Build SOQL inline in a place of need** - Business-specific SOQLs should be built inline via `SOQL` builder in a place of need.
   - Most of the queries on the project are case-specific and are not generic. There is no need to keep them in the Selector class.
3. **Build SOQL dynamically via builder** - Developers should be able to adjust queries with specific fields, conditions, and other SOQL clauses.
4. **Do not spend time on selector methods naming** - It can be difficult to find a proper name for a method that builds a query. The selector class contains methods like `selectByFieldAAndFieldBWithDescOrder`. It can be avoided by building SOQL inline in a place of need.
5. **Control FLS and sharing settings** - Selector should allow to control Field Level Security and sharing settings by simple methods like `.systemMode()`, `.withSharing()`, `.withoutSharing()`.
6. **Auto binding** - The selector should be able to bind variables dynamically without additional effort from the developer side.
7. **Mock results in Unit Tests** - The selector should allow mocking data in unit tests.

## Concepts

SOQL Library consist of:

- `SOQL Builder`
- `SOQL Selector`

## SOQL Builder

SOQL Builder allows to build query dynamically and execute it.

```apex
// SELECT Id, Name, Industry FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(Account.Id, Account.Name, Account.Industry)
   .toList();
```

## SOQL Selector

> A selector layer contains code responsible for querying records from the database. Although you can place SOQL queries in other layers, a few things can happen as the complexity of your code grows. ~ Salesforce

**SOQL Lib provides the whole new concept for Selectors usage.**

### Old Approach

[FFLIB Selector](https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectSelector.cls) concept assumes that all queries  should be stored in the Selector class.

- To avoid duplicates.
- One place to manage all queries.

**Issues**:
- One-time queries (like aggregation, case specific) added to Selector.
- Huge class with a lot of methods.
- Queries are difficult to reuse.
- Similar methods with small differences like limit, offset.
- Problem with naming methods.
- Merge conflicts.

### New Approach

The SOQL Lib has a slightly different approach.

**Assumption**:

Most of the SOQLs on the project are **one-time** queries executed for specific business case.

**Solution**:
1. **Small Selector Classes** - Selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`byId`, `byRecordType`)
2. **Build SOQL inline in a place of need** - Business-specific SOQLs should be built inline via the SOQL builder in the place of need.
3. **Do not spend time on selector methods naming** - Queries are created inline, so there's no need to find a name.
4. **Keep Selector Strengths** - Set default Selector configuration (default fields, sharing settings), keep generic methods.

### Build Your Own Selector

SOQL-Lib is agile, so you can adjust the solution according to your needs. We don't force one approach over another, you can choose your own. Here are our propositions:

#### A - Inheritance - extends SOQL, implements Interface + static

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Account byRecordType(String rt) {
        whereAre(Filter.recordType().equal(rt));
        return this;
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
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.name().contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .toList();
    }

    @AuraEnabled
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query()
            .byRecordType(recordType)
            .byIndustry('IT')
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }

    @AuraEnabled
    public static String getAccountIndustry(Id accountId) {
        return SOQL_Account.query().toIndustry(accountId);
    }
}
```

#### B - Composition - implements Interface + static

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

    public static SOQL byRecordType(String rt) {
        return query()
            .whereAre(SOQL.Filter.recordType().equal(rt));
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

#### C - Inheritance - extends SOQL + non-static

```apex
public inherited sharing class SOQL_Account extends SOQL {
    public SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Account byRecordType(String rt) {
        whereAre(Filter.recordType().equal(rt));
        return this;
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

#### D - Composition - implements Interface + non-static

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

#### E - Custom

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
