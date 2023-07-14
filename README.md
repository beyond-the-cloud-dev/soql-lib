# SOQL Lib

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/soql-lib/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib)

The SOQL Lib provides functional constructs for SOQL queries in Apex.

For more details, please refer to the [documentation](https://soql-lib.vercel.app/).

## Examples

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

**Composition**

```apex
public inherited sharing class SOQL_Contact implements SOQL.Selector {
    public static SOQL query() {
        // default settings
        return SOQL.of(Contact.SObjectType)
            .with(Contact.Id, Contact.Name, Contact.AccountId)
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byRecordType(String rt) {
        return query()
            .whereAre(SOQL.Filter.recordType().equal(rt));
    }

    public static SOQL byAccountId(Id accountId) {
        return query()
            .whereAre(SOQL.Filter.with(Contact.AccountId).equal(accountId));
    }
}
```

**Inheritance**

```apex
public inherited sharing class SOQL_Account extends SOQL {
    public SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public SOQL_Account byRecordType(String rt) {
        whereAre(Filter.recordType().equal(rt));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        with(Account.ParentId)
            .whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }
}

```

**Usage**

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Contact> getContacts() {
        return SOQL_Contact.query().with(Contact.Email).toList();
    }

    @AuraEnabled
    public static List<Account> getAccounts(Id parentId) {
        return new SOQL_Account().byParentId(parentId).with(Account.Industry).toList();
    }
}
```

## Deploy to Salesforce

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=soql-lib&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Read the documentation

[Query Selector documentation](https://soql-lib.vercel.app/)

## Assumptions

1. **Small Selector Classes** - The selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`byId`, `byRecordType`). Why?
   - Huge classes are hard to manage.
   - A lot of merge conflicts.
   - Problems with methods naming.
2. **Build SOQL inline in a place of need** - Business-specific SOQLs should be built inline via `SOQL` builder in a place of need.
   - Most of the queries on the project are case-specific and are not generic. There is no need to keep them in the Selector class.
3. **Build SOQL dynamically via builder** - Developers should be able to adjust queries with specific fields, conditions, and other SOQL clauses.
4. **Do not spend time on selector methods naming** - It can be difficult to find a proper name for a method that builds a query. The selector class contains methods like `selectByFieldAAndFieldBWithDescOrder`. It can be avoided by building SOQL inline in a place of need.
5. **Control FLS and sharing settings** - Selector should allow to control Field Level Security and sharing settings by simple methods like `.systemMode()`, `.withSharing()`, `.withoutSharing()`.
6. **Auto binding** - The selector should be able to bind variables dynamically without additional effort from the developer side.
7. **Mock results in Unit Tests** - Selector should allow for mocking data in unit tests.

----

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: Copyright (c) 2023 BeyondTheCloud.Dev
