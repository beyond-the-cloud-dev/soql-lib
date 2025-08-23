---
sidebar_position: 15
---

# Overview

## Concept

SOQL Lib is a modern Apex library designed as an intuitive alternative to the popular [FFLib Selectors](https://github.com/apex-enterprise-patterns/fflib-apex-common) framework. While FFLib was created over 10 years ago, we believe it hasn't kept up with modern Apex development practices, becoming a complex and cumbersome solution that often makes code more complicated than necessary.

Drawing from the best aspects of FFLib and other selector patterns, we've built SOQL Lib to be intuitive, performant, and reliable. This library is part of the Beyond The Cloud ecosystem, designed specifically for modern Salesforce development.

## Design Principles

We built SOQL Lib based on several key design principles that address common pain points in Salesforce development:

1. **Lightweight Selector Classes** - Selector classes should remain focused and contain only essential query configurations (default fields, sharing settings) and generic, chainable methods like `byId()`, `byRecordType()`, and `byParentId()`. We avoid storing all queries in selector classes because:
   - Large selector classes become difficult to maintain and navigate
   - They create frequent merge conflicts in team environments  
   - Complex query methods lead to unwieldy naming conventions

2. **Inline Query Construction** - Business-specific queries should be built inline using the `SOQL` builder exactly where they're needed:
   - Most queries in a project are context-specific rather than reusable
   - Developers can construct queries dynamically using our fluent API
   - This approach eliminates the need for countless specialized selector methods

3. **Dynamic Query Building** - The library provides full flexibility to adjust queries with specific fields, conditions, and SOQL clauses at runtime, enabling responsive and adaptable code.

4. **Simplified Method Naming** - By building queries inline, developers avoid the complexity of naming methods like `selectByFieldAAndFieldBWithDescOrder()`. The fluent API speaks for itself.

5. **Granular Security Controls** - Built-in support for Field-Level Security and sharing settings through intuitive methods like `.systemMode()`, `.withSharing()`, and `.withoutSharing()`.

6. **Automatic Variable Binding** - Dynamic variable binding eliminates boilerplate code and reduces the potential for binding errors.

7. **Comprehensive Testing Support** - Native mocking capabilities make unit testing SOQL queries straightforward and reliable.

8. **Performance Optimization** - Query results can be cached at multiple levels (Org Cache, Session Cache, Apex Transaction Cache) to improve application performance.

9. **Developer Experience** - The API is designed to be intuitive and self-documenting, minimizing the learning curve while maximizing productivity.

## Architecture

SOQL Lib consists of three distinct modules, each designed to address different use cases and development preferences:

### [`SOQL`](../soql/getting-started.md) - Core Module

The foundation of SOQL Lib, providing a comprehensive fluent API for constructing and executing SOQL queries. This module includes both SOQL Builder for direct query construction and SOQL Selectors for reusable query patterns. The architecture is flexible—developers can build queries directly without selectors or leverage selectors for commonly used query configurations.

**Key Features:**
- Fluent API for intuitive query construction
- Field-Level Security enforcement with `withUserMode()` and `systemMode()`
- Granular sharing control (`withSharing()` and `withoutSharing()`)
- Automatic variable binding and SOQL injection prevention
- Comprehensive result transformation methods
- Built-in mocking support for unit tests

```apex
// SELECT Id, Name, Industry FROM Account WITH USER_MODE
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(Account.Id, Account.Name, Account.Industry)
   .toList();
```

### [`Cache`](../cache/getting-started.md) - Performance Module _(Optional)_

An optional but highly recommended module that dramatically improves application performance by caching query results across different storage levels. Ideal for frequently accessed, slowly-changing data such as configuration records, metadata, and reference data.

**Key Features:**
- Multi-level caching: Org Cache, Session Cache, and Apex Transaction Cache
- Automatic cache expiration with `maxHoursWithoutRefresh()`
- Built-in cache management and removal capabilities

```apex
// Cached query with 24-hour refresh policy
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInOrgCache()
    .maxHoursWithoutRefresh(24)
    .toObject();
```

### [`Evaluator`](../evaluator/getting-started.md) - Legacy Bridge Module _(Optional)_

Designed for developers who prefer traditional SOQL syntax but want to leverage SOQL Lib's enhanced capabilities. This module processes static query result, providing advanced result transformation methods and mocking capabilities without requiring adoption of the full SOQL Builder syntax.

**Key Features:**
- Process results from standard SOQL queries
- Enhanced result transformation methods (`toIds()`, `toValueOf()`, `toMap()`, etc.)
- Simplified mocking for unit tests
- Field-Level Security processing with `stripInaccessible()`
- Zero learning curve for traditional SOQL developers

```apex
// Enhanced processing of standard SOQL results
Set<Id> accountIds = SOQLEvaluator.of([SELECT Id FROM Account]).toIds();
Boolean hasAccounts = SOQLEvaluator.of([SELECT Id FROM Account]).doExist();
```