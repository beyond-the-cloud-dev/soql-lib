---
sidebar_position: 10
---

# Getting Started

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/soql-lib/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib)

The SOQL Lib provides functional constructs for SOQL queries in Apex. 

:::danger[SOQL Lib Modules]

- [SOQL](./soql/getting-started) - the main module of the lib provides functional constructs for queries.
- [Cache](./cache/getting-started) _(optional)_ - Use when you want to cache query results.
- [Evaluator](./evaluator/getting-started) _(optional)_ - Use when you don't want to learn the lib.
:::

**What Next?**

- Continue with the [Overview](overview.md) to understand the idea behind the SOQL Lib. 🚀
- [Install](installation.md) the SOQL Lib in your org.

## Quick Start

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

## Resources

- [SOQL Lib Explanation](https://blog.beyondthecloud.dev/blog/soql-lib)
- [Why do you need Apex Selector Layer?](https://blog.beyondthecloud.dev/blog/why-do-you-need-selector-layer)
- [Trying out SOQL Lib - Sandbox Sessions - CloudBites TV](https://youtu.be/pVtmmJSNnRA?t=2444)
- [AWAF Selector Classes](https://awaf.dev/AWAF/selector-classes.html)
- [Good Day, Sir! Salesforce podcast](https://www.gooddaysirpodcast.com/309)

## License notes

- For proper license management, each repository should contain a LICENSE file similar to this one.
- Each original class should contain a copyright mark: Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
