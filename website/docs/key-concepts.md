---
sidebar_position: 2
---

# Key Concepts

## Assumptions

1. **Small Selector Classes** - Selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`getById`, `getByRecordType`). Why?
   - Huge classes are hard to manage.
   - A lot of merge conflicts.
   - Problems with methods naming.
2. **Build SOQL inline in a place of need** - Business specific SOQLs should be build inline via `SOQL` builder in a place of need.
   - Most of the queries on the project are case specific and are not generic. There is no need to keep them in Selector class.
3. **Build SOQL dynamically via builder** - Developer should be able to adjust query with specific fields, conditions, and other SOQL clauses.
4. **Do not spend time on selector methods naming** - It can be difficult to find a proper name for method that builds a query. Selector class contains methods like `selectByFieldAAndFieldBWithDescOrder`. It can be avoided by building SOQL inline in a place of need.
5. **Controll FLS and sharing settings** - Selector should allow to control Field Level Security and sharing settings by the simple methods like `.systemMode()`, `.withSharing()`, `.withoutSharing()`.
6. **Auto binding** - Selector should be able to bind variables dynamically without additional effort from developer side.
7. **Mock results in Unit Tests** - Selector should allow for mocking data in unit tests.

## Concepts

SOQL Library consist of:

- `SOQL Builder`
- `SOQL Selector`

## SOQL Builder

SOQL Builder allows to build query dynamically and execute it.

```apex
// SELECT Id, Name, Industry FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(new List<SObjectField>{
      Account.Id, Account.Name, Account.Industry
   }).toList();
```

## SOQL Selector

> A selector layer contains code responsible for querying records from the database. Although you can place SOQL queries in other layers, a few things can happen as the complexity of your code grows. ~ Salesforce

**SOQL Lib provides the whole new concept for Selectors usage.**

### Old Approach

[FFLIB Selector](https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectSelector.cls) concept assumes that all queries are be stored in Selector class.

- To avoid duplicates.
- One place to manage all queries.

**Issues**:
- One-time queries (like aggregation, case specific) added to Selector.
- Huge class with a lot of methods.
- Queries are difficult for reuse.
- Similar methods with small differences like limit, offset.
- Problem with naming methods.
- Merge conflicts.

### New Approach

SOQL Lib has slightly different approach.

**Assumption**:

Most of the SOQLs on the project are one-time queries executed for specific business case.

**Solution**:
1. **Small Selector Classes** - Selector class should be small and contains ONLY query base configuration (fields, sharing settings) and very generic methods (`byId`, `byRecordType`)
2. **Build SOQL inline in a place of need** - Business specific SOQLs should be build inline via SOQL builder in a place of need.
3. **Do not spend time on selector methods naming** - Queries are created inline, so not need to find a name.
4. **Keep Selector Strengths** - Set default Selector configuration (default fields, sharing settings), keep generic methods.

### Build Your Own Selector

Our Lib does NOT provide one method to build selectors. Select approach that meet you needs. Below you will find a few examples:

#### Interface + static (Recommended)

Use `SOQL.Selector` and create `static` methods.

```apex
public with sharing class AccountSelector implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
    }

    public static SOQL getByRecordType(String rt) {
        return query.with(new List<SObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
```

```apex
public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return AccountSelector.query()
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.Filter.with(Account.Name).contains(accountName))
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
```

#### Interface + non-static

Very useful when you have different teams/streams who need different query configuration.

```apex
public with sharing virtual class BaseAccountSelector implements SOQL.Selector {
    public virtual SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Id,
                Account.Name
            });
    }

    public SOQL byRecordType(String rt) {
        return query().with(new List<SObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
```

```apex
public with sharing class MyTeam_AccountSelector extends BaseAccountSelector implements SOQL.Selector {
    public override SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Id,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
    }
}
```

```apex
public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return new MyTeam_AccountSelector().query()
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.Filter.with(Account.Name).contains(accountName))
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return new MyTeam_AccountSelector().byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
```

#### Custom

Create Selectors in your own way.

```apex
public with sharing virtual class AccountSelector  {
    public static SOQL query {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Id,
                Account.Name
            });
    }

    public static SOQL byRecordType(String rt) {
        return query.with(new List<SObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
```

```apex
public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return AccountSelector().query
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.Filter.with(Account.Name).contains(accountName))
            .toList();
    }

    public static List<Account> getAccountsByRecordType(String recordType) {
        return AccountSelector.byRecordType(recordType)
                .with(Account.ParentId)
                .toList();
    }
}
```
