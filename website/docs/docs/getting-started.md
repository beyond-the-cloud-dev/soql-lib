---
slug: '/'
sidebar_position: 10
---

# Getting Started

Read about the SOQL Lib in [blog post](https://beyondthecloud.dev/blog/soql-lib).

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/soql-lib/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib)

The SOQL Lib provides functional constructs for SOQL queries in Apex.

## Examples

**Standard SOQL**

```apex
// SELECT Id FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType).toList();
```

```apex
// SELECT Id, Name, Industry FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(Account.Id, Account.Name, Account.Industry)
   .toList();
```

**Cached SOQL**

```apex
// SELECT Id, Name, UserType FROM Profile WHERE Name = 'System Administrator'
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
            .with(Contact.Email, Contact.Department)
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

1. **Additional level of abstraction** - The selector layer is an additional level of abstraction that gives you the possibility to control the execution of SOQL.
2. **Mocking** - Selector classes give a possibility to mock return values in unit tests.
    - Mock external objects (__x) - External objects cannot be inserted in unit tests. You need to mock them.
    - Mock custom metadata - Custom metadata cannot be inserted in unit tests unless the developer uses the Metadata API. Mock can be a solution.
3. **Control field-level security** - The best practice is to execute SOQLs `WITH USER_MODE` to enforce field-level security and object permissions of the running user. The selector layer can apply `WITH USER_MODE` by default to all of the queries, so the developer does not need to care about it. Developers can also add `WITH SYSTEM_MODE` to all SOQLs from a specific selector.
4. **Control sharings rules** - The selector allows to execute of different methods in the same class in different sharing modes.
5. **Avoid duplicates** - Generic SQOLs like `getById`, and `getByRecordType` can be stored in the selector class.
6. **Default configuration** - The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.
7. **Mocking** - The selector class has built in Mocking functionality that provides ability to dynamically return data in test execution
8. **Caching** - The cached selector class allows you to cache records in Apex transactions, Session Cache, or Org Cache, which boosts your code's performance.

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
