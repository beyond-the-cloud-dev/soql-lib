# SOQL Lib

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/query-selector/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/query-selector/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/query-selector)

Apex SOQL provides functional constructs for SOQL.


Find more details in the [documentation](https://soql-lib.vercel.app/).

## Examples

```apex
// SELECT Id FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType).asList();
```

```apex
// SELECT Id, Name, Industry FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(new List<SObjectField>{
      Account.Id, Account.Name, Account.Industry
   }).asList();
```
## Deploy to Salesforce

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=query-selector&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Read the documentation

[Query Selector documentation](https://soql-lib.vercel.app/)

## Assumptions

1. **Small Selector Classes** - Selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`getById`, `getByRecordType`). Why?
   - Huge classes are hard to manage.
   - A lot of merge conflicts.
   - Problems with methods naming.
2. **Build SOQL inline in a place of need** - Business specific SOQLs should be build inline via `SOQL` builder in a place of need.
   - Most of the queries on the project are case specific and are not generic. There is no need to keep them in Selector class.
3. **Build SOQL dynamically via builder** - Developer should be able to adjust query with specific fields, conditions, and other SOQL clauses.
4. **Do not spend time on selector methods naming** - It can be difficult to find a proper name for method that builds a query. Selector class contains methods like `selectByFieldAAndFieldBWithDescOrder`. It can be avoided by building SOQL inline in a place of need.
5. **Controll FLS ans sharing settings** - Selector should allow to control Field Level Security and sharing settings by the simple methods like `.systemMode()`, `.withSharing()`, `.withoutSharing()`.
6. **Auto binding** - Selector should be able to bind variables dynamically without additional effort from developer side.
7. **Mock results in Unit Tests** - Selector should allow for mocking data in unit tests.

----

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
