---
name: soql-lib-selector
description: SOQL Lib selector classes (SOQL_Account-style classes that extend SOQL and implement SOQL.Selector). Use when creating a selector for an SObject, adding or reviewing selector filter methods, deciding whether a query belongs in a selector or inline, or calling a selector from a service, controller, batch or trigger handler, in a project that contains SOQL.cls. Not for SOQLCache cached selectors.
---

# SOQL Lib: Selectors

A selector holds the shared setup for one SObject: default fields, security mode and mock id. It also holds a few reusable filters. Conditions that only one piece of business logic needs stay inline, chained onto `SOQL_<Object>.query()` where they are used.

## Before writing

1. Look for existing selectors (`SOQL_*.cls`, or other classes that `extends SOQL`). If the project's selectors differ from the template below, for example in naming, static composition or security defaults, follow the project.
2. Use one selector per SObject. If a selector already exists, add to it rather than creating a second one, and don't create an `AccountSelector` next to `SOQL_Account`.

## Template

```apex
public inherited sharing class SOQL_Opportunity extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'SOQL_Opportunity';

    public static SOQL_Opportunity query() {
        return new SOQL_Opportunity();
    }

    private SOQL_Opportunity() {
        super(Opportunity.SObjectType);
        with(Opportunity.Id, Opportunity.Name, Opportunity.StageName, Opportunity.CloseDate);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Opportunity byAccountIds(Set<Id> accountIds) {
        whereAre(Filter.with(Opportunity.AccountId).isIn(accountIds));
        return this;
    }

    public SOQL_Opportunity byStage(String stageName) {
        whereAre(Filter.with(Opportunity.StageName).equal(stageName).ignoreWhen(String.isBlank(stageName)));
        return this;
    }

    public SOQL_Opportunity isOpen() {
        whereAre(Filter.with(Opportunity.IsClosed).isFalse());
        return this;
    }
}
```

| Part | Rule | Why |
|---|---|---|
| Class name | `SOQL_<Object>`. For a custom object drop `__c`: `SOQL_Invoice` for `Invoice__c` | Apex class names can't contain `__` |
| Sharing keyword | `inherited sharing` | `.systemMode()` without an explicit sharing call takes the caller's sharing |
| Factory | `public static <Selector> query()` | every caller starts from a fresh query |
| Constructor | `private`, with `super(<Object>.SObjectType)` first | instances come only from `query()` |
| Default fields | only the fields most callers need | callers add more with `.with(...)` |
| Security | `systemMode(); withoutSharing();` | every caller gets the selector's access. Only a caller that must apply the running user's access calls `.userMode()` |
| Mock id | `@TestVisible private static final String MOCK_ID = '<class name>';` then `mockId(MOCK_ID)` as the last constructor call | tests use `SOQL.mock(SOQL_Opportunity.MOCK_ID)` |
| Filter method | returns the selector type, calls `whereAre(Filter...)` (no `SOQL.` prefix needed), ends with `return this;` | callers can keep chaining selector methods |
| Optional parameter | `.ignoreWhen(<empty check>)` on the filter | callers don't need `if` branches |
| Constructor WHERE | none | every caller would inherit the condition |

## What belongs in the selector

- Put a filter in the selector when two or more places use it, or when it names a business concept (`isOpen()`, `byAccountIds()`).
- Keep these inline at the call site: one-off conditions, ORDER BY, LIMIT, extra fields, aggregates and the result method.
- Filter methods return the selector, never `List<SObject>`. Callers then decide on fields, ordering, limits and the result method.
- To reuse an inherited shortcut and keep chaining, wrap it: `public SOQL_Contact byRecordTypeName(String name) { byRecordType(name); return this; }`.

## Calling a selector

```apex
public static List<Opportunity> getOpenOpportunities(Id accountId) {
    return SOQL_Opportunity.query()
        .byAccountIds(new Set<Id>{ accountId })   // selector methods first
        .isOpen()
        .with(Opportunity.Amount)                 // then inherited SOQL methods
        .with('Account', Account.Name)
        .orderBy(Opportunity.CloseDate).sortDesc()
        .setLimit(50)
        .toList();
}
```

- Call selector methods first. Inherited methods (`with`, `whereAre`, `byId`, `orderBy`, `setLimit`, ...) return `SOQL.Queryable`, which has no selector methods.
- User mode is SOQL Lib's default, so call `.userMode()` only to switch a selector that set `.systemMode()` back to the running user's access: `SOQL_Opportunity.query().isOpen().userMode().toList()`. Don't add `.withSharing()` next to it, because user mode always enforces sharing.
- Counts and aggregates can go through the selector. Grouping and `toInteger()` drop the default fields: `SOQL_Opportunity.query().isOpen().toInteger()`.
- OR between selector filters: `.anyConditionMatching()`, or `.conditionLogic('1 OR 2')` for custom logic.
- Batch `start()`: `return SOQL_Opportunity.query().isOpen().toQueryLocator();`.
- For the full builder API (filters, result methods, security table), use the `soql-lib-query-builder` skill. For tests, use `soql-lib-testing`.

## Common mistakes

| Mistake | Fix |
|---|---|
| Filter method returns `SOQL.Queryable` | Return the selector type and `this`. |
| `.with(...)` or `.byId(...)` called before a selector method, so it doesn't compile | Reorder: selector methods first. |
| Public constructor, or missing `query()` | Private constructor plus static `query()`. |
| No `mockId(MOCK_ID)`, or `MOCK_ID` doesn't match the class name | Add it, using the class name as the value. |
| `.userMode()` on a query that is already in user mode (`SOQL.of(...)`, or a selector without `systemMode()`) | Remove it. User mode is the default. |
| `.userMode().withSharing()` | Drop `.withSharing()`. User mode always enforces sharing. |
| Selector method ends with `.toList()` | Return `this`. The caller picks the result method. |
| Every field of the object in the constructor | Keep the defaults small. Callers add fields. |
