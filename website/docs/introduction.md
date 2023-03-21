---
sidebar_position: 1
slug: '/'
---

# Introduction

[Learn Selector Layer Principles](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl/apex_patterns_dsl_learn_selector_l_principles)

> A selector layer contains code responsible for querying records from the database. Although you can place SOQL queries in other layers, a few things can happen as the complexity of your code grows. ~ Salesforce

In terms of Separation of Concerns, a Selector concerns itself with providing the following:
- **Visibility, reusability, and maintainability** - The selector makes it easy to find and maintain database query logic.
- **Predictability of queried data** - It must be clear what the selector is doing in the method name and what it’s returning.
- **Security** - Provide a means for the caller to opt in or opt out (for system level scenarios) of security checks that enforce sharing and permissions applied to the current user context.
- **Platform sympathy** - Make queries as optimal as possible, mainly expressing criteria via sets, thus encouraging the caller to be bulkified in its code when calling the selector methods.

## Benefits

1. **Additional level of abstraction** - The selector layer is an additional level of abstraction that gives you the possibility to control the execution of SQOL.
2. **Mocking** - Selector classes give a possibility to mock return values in unit tests.
    - Mock external objects (__x) - External objects cannot be inserted in unit tests. You need to mock them.
    - Mock custom metadata - Custom metadata cannot be inserted in unit tests unless the developer uses the Metadata API. Mock can be a solution.
3. **Control field-level security** - The best practice is to execute SOQLs `WITH USER_MODE` to enforce field-level security and object permissions of the running user. The selector layer can apply `WITH USER_MODE` by default to all of the queries, so the developer does not need to care about it. Developers can also add `WITH SYSTEM_MODE` to all SOQLs from a specific selector.
4. **Control sharings rules** - The selector allows to execute of different methods in the same class in different sharing modes.
5. **Avoid duplicates** - Generic SQOLs like `getById`, and `getByRecordType` can be stored in the selector class.
6. **Default configuration** - The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.
