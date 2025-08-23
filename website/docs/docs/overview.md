---
sidebar_position: 15
---

# Overview

## Assumptions

1. **Small Selector Classes** - The selector class should be small and contain ONLY query base configuration (fields, sharing settings) and very generic methods (`byId`, `byRecordType`). Why?
   - Huge classes are hard to manage.
   - A lot of merge conflicts.
   - Problems with method naming.
2. **Build SOQL inline in a place of need** - Business-specific SOQLs should be built inline via `SOQL` builder in a place of need.
   - Most of the queries on the project are case-specific and are not generic. There is no need to keep them in the Selector class.
3. **Build SOQL dynamically via builder** - Developers should be able to adjust queries with specific fields, conditions, and other SOQL clauses.
4. **Do not spend time on selector method naming** - It can be difficult to find a proper name for a method that builds a query. The selector class contains methods like `selectByFieldAAndFieldBWithDescOrder`. It can be avoided by building SOQL inline in a place of need.
5. **Control FLS and sharing settings** - Selector should allow to control Field Level Security and sharing settings by simple methods like `.systemMode()`, `.withSharing()`, `.withoutSharing()`.
6. **Auto binding** - The selector should be able to bind variables dynamically without additional effort from the developer side.
7. **Mock results in Unit Tests** - The selector should allow mocking data in unit tests.

## Concepts

SOQL Library consists of:

- `SOQL Builder`
- `SOQL Selector`

## SOQL Builder

SOQL Builder allows you to build queries dynamically and execute them.

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

[FFLIB Selector](https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectSelector.cls) concept assumes that all queries should be stored in the Selector class.

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

Most of the SOQLs on the project are **one-time** queries executed for specific business cases.

**Solution**:
1. **Small Selector Classes** - Selector class should be small and contain ONLY query base configuration (fields, sharing settings) and very generic methods (`byId`, `byRecordType`)
2. **Build SOQL inline in a place of need** - Business-specific SOQLs should be built inline via the SOQL builder in the place of need.
3. **Do not spend time on selector method naming** - Queries are created inline, so there's no need to find a name.
4. **Keep Selector Strengths** - Set default Selector configuration (default fields, sharing settings), keep generic methods.
