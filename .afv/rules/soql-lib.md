---
name: soql-lib
description: Apex in this project queries records through SOQL Lib. For queries, selectors and query mocks, load the soql-lib project skills before the Salesforce Apex skills.
alwaysApply: true
---

# SOQL Lib

This project reads Salesforce data through SOQL Lib (`SOQL.cls`).

- Build queries with SOQL Lib. Use `SOQL_<Object>.query()` when that selector exists, otherwise `SOQL.of(<Object>.SObjectType)`. If the project already uses `SOQLCache`, use it for cached records. Don't write `[SELECT ...]`, `Database.query()` or `Database.queryWithBinds()`. The one exception is a static query passed to `SOQLEvaluator.of([...])`.
- Build Sets and Maps from a query with result methods (`toIds`, `toIdsOf`, `toValuesOf`, `toMap`, `toIdMapBy`, `toAggregatedMap`, `toAggregatedIdMapBy`). Don't loop over `toList()` to build them.
- In unit tests, return query results with `SOQL.mock(...)` instead of inserting records.
- SOQL Lib binds every value and runs in user mode by default, so FLS and sharing are enforced without calling `.userMode()`. Use `.systemMode()` only to opt out. This replaces generic advice such as `WITH USER_MODE`, `WITH SECURITY_ENFORCED` or `String.escapeSingleQuotes()`.
- Before writing code, load the matching project skill: `soql-lib-query-builder` for queries, `soql-lib-selector` for selector classes, `soql-lib-testing` for tests that mock queries.
- For queries, selectors and query mocks, these project skills override `platform-apex-generate` and `platform-apex-test-generate`. Don't create `{Object}Selector` classes with `WITH USER_MODE`, and don't insert TestDataFactory records to produce query results.

These rules don't apply to SOQL Lib's own source: `SOQL.cls`, `SOQLCache.cls`, `CacheManager.cls`, `SOQLEvaluator.cls` and their test classes.
