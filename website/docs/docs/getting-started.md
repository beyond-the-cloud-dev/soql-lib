---
slug: '/getting-started'
sidebar_position: 10
---

# Getting Started

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/soql-lib/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib)

The SOQL Lib provides functional constructs for SOQL queries in Apex. The SOQL Lib consists of 3 main modules:

- [SOQL (main)](./soql/getting-started) - SOQL Builder and Selectors
- [Cache (optional)](./cache/getting-started) - Cached SOQL Builder and Cached Selectors
- [Evaluator (optional)](./evaluator/getting-started) - SOQL Evaluator

## Examples

**Standard SOQL**

```apex
// SELECT Id FROM Account WITH USER_MODE
List<Account> accounts = SOQL.of(Account.SObjectType).toList();
```

```apex
// SELECT Id, Name, Industry FROM Account WITH USER_MODE
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(Account.Id, Account.Name, Account.Industry)
   .toList();
```

**Cached SOQL**

```apex
// SELECT Id, Name, UserType 
// FROM Profile 
// WHERE Name = 'System Administrator' 
// WITH SYSTEM_MODE
Profile systemAdminProfile = (Profile) SOQLCache.of(Profile.SObjectType)
   .with(Profile.Id, Profile.Name, Profile.UserType)
   .whereEqual(Profile.Name, 'System Administrator')
   .toObject();
```

## Selector

```apex
public inherited sharing class SOQL_Contact extends SOQL implements SOQL.Selector {
    public static SOQL_Contact query() {
        return new SOQL_Contact();
    }

    private SOQL_Contact() {
        super(Contact.SObjectType);
        // default settings
        with(Contact.Id, Contact.Name, Contact.AccountId)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Contact byAccountId(Id accountId) {
        whereAre(Filter.with(Contact.AccountId).equal(accountId));
        return this;
    }

    public SOQL_Contact bySource(String source) {
        whereAre(Filter.with(Contact.ContactSource).equal(source));
        return this;
    }
}
```

**Usage**

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Contact> getAccountContacts(Id accountId) {
        return SOQL_Contact.query()
            .byAccountId(accountId)
            .bySource('Website')
            .with(Contact.Email, Contact.Department) // additional fields
            .toList();
    }
}
```

## Cached Selector

```apex
public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        with(Profile.Id, Profile.Name, Profile.UserType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType);
    }

    public SOQL_ProfileCache byName(String name) {
        whereEqual(Profile.Name, name);
        return this;
    }
}
```

**Usage**

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static void createNewAdministrator(User newUser) {
        Profile adminProfile = (Profile) SOQL_ProfileCache.query()
            .byName('System Administrator')
            .toObject();

        newUser.ProfileId = adminProfile.Id;
        insert newUser;
    }
}
```

## Benefits

Check the [Basic Features](./basic-features.md) section for more details.

1. **Additional level of abstraction** - The selector layer is an additional level of abstraction that gives you the possibility to control the execution of SOQL.
2. **Mocking** - Selector classes give a possibility to mock return values in unit tests.
    - Mock external objects (__x) - External objects cannot be inserted in unit tests. You need to mock them.
    - Mock custom metadata - Custom metadata cannot be inserted in unit tests unless the developer uses the Metadata API. Mock can be a solution.
3. **Control field-level security** - The best practice is to execute SOQLs `WITH USER_MODE` to enforce field-level security and object permissions of the running user. The selector layer can apply `WITH USER_MODE` by default to all of the queries, so the developer does not need to care about it. Developers can also add `WITH SYSTEM_MODE` to all SOQLs from a specific selector.
4. **Control sharing rules** - The selector allows execution of different methods in the same class in different sharing modes.
5. **Avoid duplicates** - Generic SOQLs like `getById` and `getByRecordType` can be stored in the selector class.
6. **Default configuration** - The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.
7. **Mocking** - The selector class has built-in mocking functionality that provides the ability to dynamically return data in test execution
8. **Caching** - The cached selector class allows you to cache records in Apex transactions, Session Cache, or Org Cache, which boosts your code's performance.
9. **Result Functions** - Transform your results easily using result SOQL Lib functions.

## Resources

- [SOQL Lib Explanation](https://blog.beyondthecloud.dev/blog/soql-lib)
- [Why do you need Apex Selector Layer?](https://blog.beyondthecloud.dev/blog/why-do-you-need-selector-layer)

## License notes

- For proper license management, each repository should contain a LICENSE file similar to this one.
- Each original class should contain a copyright mark: Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
