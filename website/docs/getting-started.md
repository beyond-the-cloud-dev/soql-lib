---
slug: '/'
sidebar_position: 2
---

# Getting started

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/query-selector/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/query-selector/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/query-selector)

Apex SOQL provides functional constructs for SOQL.

## Examples

```apex
//SELECT Id FROM Account
List<Account> accounts = SOQL.of(Account.sObjectType).asList();
```

```apex
//SELECT Id, Name, Industry, Country FROM Account
List<Account> accounts = SOQL.of(Account.sObjectType)
   .with(new List<sObjectField>{
      Account.Id, Account.Name, Account.Industry, Account.Country
   }).asList();
```

## Assumptions

1. **Small Selector Classes** - Selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`getById`, `getByRecordType`). Why?
   - Huge classes are hard to manage.
   - A lot of merge conflicts.
   - Problems with methods naming.
2. **Build SOQL inline in a place of need** - Business specific SOQLs should be build inline via `SOQL` builder in a place of need.
   - Most of the queries on the project are case specific and are not generic. There is no need to keep them in Selector class.
3. **Build SOQL dynamically via builder** - Developer should be able to adjust query with specific fields, conditions, and other SOQL clauses.
4. **Do not spend time on selector methods naming** - It can be difficult to find a proper name for method that builds a query. Selector class contains methods like `selectByFieldAAndFieldBWithDescOrder`. It can be avoided by building SOQL inline in a place of need.
5. **Controll FLS ans sharing settings** - Selector should allow to control Field Level Security and sharing settings by the simple methods like `.systemMode()`, `.withSharing()`, `.withoutSharing()`.
6. **Auto binding** - Selector should be able to bind variables dynamically without additional effort from developer side.
7. **Mock results in Unit Tests** - Selector should allow for mocking data in unit tests.

## Introduction

SOQL Library consist of:
- `SOQL Builder`
- `SOQL Selector`

### SOQL Builder

SOQL Builder allows to build query dynamically and execute it.

```apex
// SELECT Id, Name, Industry FROM Account
List<Account> accounts = SOQL.of(Account.sObjectType)
   .with(new List<sObjectField>{
      Account.Id, Account.Name, Account.Industry
}).asList();
```

### SOQL Selector

> A selector layer contains code responsible for querying records from the database. Although you can place SOQL queries in other layers, a few things can happen as the complexity of your code grows. ~ Salesforce

**SOQL Lib provides the whole new concept for Selectors usage.**

#### Old Approach

[FFLIB Selector](https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectSelector.cls) concept assumes that all queries are be stored in Selector class.

- To avoid duplicates.
- One place to manage all queries.

**Selector Issues**:
- One-time queries (like aggregation, case specific) added to Selector.
- Huge class with a lot of methods.
- Queries are difficult for reuse.
- Similar methods with small differences like limit, offset.
- Problem with naming methods.
- Merge conflicts.

#### New Approach

SOQL Lib has slightly different approach.

**Assumption**:
Most of the SOQLs on the project are one-time queries executed for specific business case.

**Solution**:
1. **Small Selector Classes** - Selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`getById`, `getByRecordType`)
2. **Build SOQL inline in a place of need** - Business specific SOQLs should be build inline via SOQL builder in a place of need.
3. **Do not spend time on selector methods naming** - Queries are created inline, so not need to find a name.
4. **Keep Selector Strengths** - Set default Selector configuration (default fields, sharing settings), keep generic methods.

```apex
public with sharing class AccountSelector {
    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType).with(new List<sObjectField>{
                Account.Name,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
        }
    }

    public static SOQL getByRecordType(String rt) {
        return Query.with(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
```

```apex
public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return AccountSelector.Query
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
            )
            .asList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.getByRecordType(recordType)
                .with(Account.ParentId)
                .asList();
    }
}
```

## Benefits

1. **Additional level of abstraction** - The selector layer is an additional level of abstraction that gives you the possibility to control the execution of SQOL.
2. **Mocking** - Selector classes give a possibility to mock return values in unit tests.
    - Mock external objects (__x) - External objects cannot be inserted in unit tests. You need to mock them.
    - Mock custom metadata - Custom metadata cannot be inserted in unit tests unless the developer uses the Metadata API. Mock can be a solution.
3. **Control field-level security** - The best practice is to execute SOQLs `WITH USER_MODE` to enforce field-level security and object permissions of the running user. The selector layer can apply `WITH USER_MODE` by default to all of the queries, so the developer does not need to care about it. Developers can also add `WITH SYSTEM_MODE` to all SOQLs from a specific selector.
4. **Control sharings rules** - The selector allows to execute of different methods in the same class in different sharing modes.
5. **Avoid duplicates** - Generic SQOLs like `getById`, and `getByRecordType` can be stored in the selector class.
6. **Default configuration** - The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
