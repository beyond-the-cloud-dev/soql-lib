<div align="center">
  <a href="https://soql.beyondthecloud.dev">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://soql.beyondthecloud.dev/img/logo.png">
      <img alt="SOQL Lib logo" src="https://soql.beyondthecloud.dev/img/logo.png" height="98">
    </picture>
  </a>
  <h1>SOQL Lib</h1>

<a href="https://beyondthecloud.dev"><img alt="Beyond The Cloud logo" src="https://img.shields.io/badge/MADE_BY_BEYOND_THE_CLOUD-555?style=for-the-badge"></a>
<a ><img alt="API version" src="https://img.shields.io/badge/api-v64.0-blue?style=for-the-badge"></a>
<a href="https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-mit-green?style=for-the-badge"></a>

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/soql-lib/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib)
</div>

# Getting Started

The SOQL Lib provides functional constructs for SOQL queries in Apex.

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
}
```

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Contact> getAccountContacts(Id accountId) {
        return SOQL_Contact.query()
            .byRecordType('Partner')
            .byAccountId(accountId)
            .with(Contact.Email)
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

## Deploy to Salesforce

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=soql-lib&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Documentation

Visit the [documentation](https://soql.beyondthecloud.dev) to view the full documentation.

## Features

Read about the features in the [basic features](https://soql.beyondthecloud.dev/soql/basic-features).

## Contributors

<a href="https://github.com/beyond-the-cloud-dev/soql-lib/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=beyond-the-cloud-dev/soql-lib" />
</a>

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
