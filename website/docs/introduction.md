---
sidebar_position: 1
slug: '/'
---

# Introduction

## Why you need it?

### Additional level of abstraction

Selector layer is an additional level of abstraction that give you a possibility to control execution of SQOL.

### Mocking

Selector classes enable you to mock their return values in unit tests.

**Test Mocking**

Mock records that will be returned via selecor without inserting it to the database. Improve unit test execution time.

**Mock external objects (__x)**

External objects cannot be inserted to the Salesforce database in unit tests. You need to mock them.

**Mock custom metadata**

Custom metadata cannot be inserted in unit tests, unless developer use the Metadata API.

### Control FLS

[Enforce User Mode for Database Operations](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm)

The best practice is to execute SOQLs `WITH USER_MODE` to enforce field-level security and object permissions of the running user.

Selector layer can apply `WITH USER_MODE` by default to all of the queries, so developer no need to care of it.

Of course there are some cases when SOQL should be executed in `WITH SYSTEM_MODE`, you also can apply it for all SOQLs from specific selector.

### Control Sharings

`WITH SYSTEM_MODE` sharing rules are controlled by sharing keywords on the class.

You cannot execute two different methods in the same class in different sharing modes.

The only why is to create additional class `without sharing`.

**Standard way**

```apex
public with sharing class MyController {

    public List<Account> getAccountsWithSharing() {
        return [SELECT Id, Name FROM Account];
    }

    public List<Account> getAccountsWithoutSharing() {
        return new MyWithoutSharingController().getAccounts();
    }

    public class without sharing MyWithoutSharingController {
        public List<Account> getAccounts() {
            return [SELECT Id, Name FROM Account];
        }
    }
}
```

**Selector**

```apex
public with sharing class MyController {

    public List<Account> getAccountsWithSharing() {
        return QS_Account.Selector.fields(new List<sObjectField>{
            Account.Id, Account.Name
        })
        .systemMode()
        .withSharing()
        .asList();
    }

    public List<Account> getAccountsWithoutSharing() {
        return QS_Account.Selector.fields(new List<sObjectField>{
            Account.Id, Account.Name
        })
        .systemMode()
        .withoutSharing()
        .asList();
    }
}
```

### Avoid duplicates

Generic SQOLs like `getById`, `getByRecordType` can be store in selector class.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id, Account.Name
                });
        }
    }

    public static QS getById(Id accountId) {
        return Selector.whereAre(QB.Condition.id().equal(accountId));
    }

    public static QS getByRecordType(String rt) {
        return Selector.whereAre(QB.Condition.recordTypeDeveloperName().equal(rt));
    }
}
```

```apex
public with sharing class MyController() {

    public Account getAccountById(Id accountId) {
        return (Account) QS_Account
            .getById(accountId)
            .fields(new List<sObjectField>{ // Additional fields
                Account.BillingCity, Account.BillingCountry
            })
            .asList();
    }
}
```

### Default configuration

Selector class can provide default SOQL configuration like default set of fields, FLS settings, sharing rules.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id, Account.Name
                })
                .systemMode()
                .withoutSharing();
        }
    }
}
```

```apex
public with sharing class MyController() {

    // Will be executed without sharing with Id, Name as default fields
    public List<Account> getAccounts() {
        return QS_Account.Selector
            .fields(new List<sObjectField>{
                Account.BillingCity, Account.BillingCountry
            })
            .asList();
    }
}
```
