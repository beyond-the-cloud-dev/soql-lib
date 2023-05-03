---
slug: '/'
sidebar_position: 2
---

# Get started

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/query-selector/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/query-selector/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/query-selector)

Apex SOQL provides functional constructs for SOQL.

## Examples

```apex
//SELECT Id FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType).toList();
```

```apex
//SELECT Id, Name, Industry, Country FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(new List<SObjectField>{
      Account.Id, Account.Name, Account.Industry, Account.Country
   }).toList();
```

## Benefits

1. **Additional level of abstraction** - The selector layer is an additional level of abstraction that gives you the possibility to control the execution of SOQL.
2. **Mocking** - Selector classes give a possibility to mock return values in unit tests.
    - Mock external objects (__x) - External objects cannot be inserted in unit tests. You need to mock them.
    - Mock custom metadata - Custom metadata cannot be inserted in unit tests unless the developer uses the Metadata API. Mock can be a solution.
3. **Control field-level security** - The best practice is to execute SOQLs `WITH USER_MODE` to enforce field-level security and object permissions of the running user. The selector layer can apply `WITH USER_MODE` by default to all of the queries, so the developer does not need to care about it. Developers can also add `WITH SYSTEM_MODE` to all SOQLs from a specific selector.
4. **Control sharings rules** - The selector allows to execute of different methods in the same class in different sharing modes.
5. **Avoid duplicates** - Generic SQOLs like `getById`, and `getByRecordType` can be stored in the selector class.
6. **Default configuration** - The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.
7. **Mocking** - The selector class has built in Mocking functionality that provides ability to dynamically return data in test execution

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: Copyright (c) 2023 BeyondTheCloud.Dev
