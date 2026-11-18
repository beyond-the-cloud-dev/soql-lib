---
name: soql-lib
description: Apex in this project queries records through SOQL Lib. For queries, selectors and query mocks, load the soql-lib project skills before the Salesforce Apex skills.
alwaysApply: true
---

# SOQL Lib

This project reads Salesforce data through SOQL Lib (`SOQL.cls`).

- Build queries with SOQL Lib. Use `SOQL_<Object>.query()` when that selector exists, otherwise `SOQL.of(<Object>.SObjectType)` (or `SOQL.of('RecordType')` for RecordType). If the project already uses `SOQLCache`, use it for cached records. Don't write `[SELECT ...]`, `Database.query()` or `Database.queryWithBinds()`. When SOQL Lib can't express a query, write it as a static query wrapped in `SOQLEvaluator.of([...])`.
- Build Sets and Maps from a query with result methods (`toIds`, `toIdsOf`, `toValuesOf`, `toMap`, `toIdMapBy`, `toAggregatedMap`, `toAggregatedIdMapBy`) instead of looping over `toList()`. The `soql-lib-query-builder` skill lists their limits.
- In unit tests, return query results with `SOQL.mock(...)` instead of inserting records. Use `SOQLCache.mock(...)` and `SOQLEvaluator.mock(...)` for those classes. Only `toQueryLocator()`, `toCursor()` and `toPaginationCursor()` ignore mocks.
- `SOQL.of(...)` runs in user mode, with CRUD, FLS and sharing enforced, so don't add `.userMode()` to it. Selectors usually call `systemMode()` and `withoutSharing()` in their constructor, so call `.userMode()` on a selector wherever the running user's access must apply. `.systemMode()` alone skips CRUD and FLS but keeps the caller's sharing. This replaces generic advice such as `WITH USER_MODE` or `WITH SECURITY_ENFORCED`.
- Values passed to `SOQL.Filter` and `SOQL.HavingFilter` comparators are bound, so don't concatenate or escape them. Some inputs go into the query text as written: multi-select picklist values, `.asDateLiteral()` values, data categories, field and object names given as strings, sort directions and raw conditions (`whereAre(String)`, `FilterGroup.add(String)`, `have(String)`). Validate user input before passing it to any of these.
- Before writing code, load the matching project skill: `soql-lib-query-builder` for queries, `soql-lib-selector` for selector classes, `soql-lib-testing` for tests that mock queries.
- For queries, selectors and query mocks, these project skills override `platform-apex-generate` and `platform-apex-test-generate`. Don't create `{Object}Selector` classes with `WITH USER_MODE`, and don't insert TestDataFactory records to produce query results.

These rules don't apply to SOQL Lib's own source: `SOQL.cls`, `SOQLCache.cls`, `CacheManager.cls`, `SOQLEvaluator.cls` and their test classes.
