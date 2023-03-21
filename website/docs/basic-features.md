---
sidebar_position: 3
---

# Basic Features

## Dynamic SOQL

`QS.cls` class provide methods that allow build SOQL clauses dynamically.

```apex
// SELECT Id FROM Account LIMIT 100
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.setLimit(100)
.asList();
```


## Automatic binding

All variables used in `WHERE` condition are binded by default.

```apex
// SELECT Id, Name FROM Account WHERE Name = :v1
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.whereAre(QS.Condition.field(Account.Name).likeAnyBoth('Test'))
.asList();
```

```apex
// Binding Map
{
  "v1" : "%Test%"
}
```

## Control FLS

[AccessLevel Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_AccessLevel.htm)

Object permission and field-level security is controlled by the framework. Developer can change FLS settings match business requirements.

### User mode

By default all queries are in `AccessLevel.USER_MODE`.

> The object permissions, field-level security, and sharing rules of the current user are enforced.

### System mode

Developer can change it by using `.systemMode()` which apply `AccessLevel.SYSTEM_MODE`.

> The object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the sharingMode.

```apex
// SELECT Id FROM Account - skip FLS
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.asList();
```

## Control Sharings

[Apex Sharing](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

> Use the with sharing or without sharing keywords on a class to specify whether sharing rules must be enforced. Use the inherited sharing keyword on a class to run the class in the sharing mode of the class that called it.

### with sharing

By default all queries will be executed `with sharing`, because of `AccessLevel.USER_MODE` which enforce sharing rules.

`AccessLevel.USER_MODE` enforce object permissions and field-level security as well.

Developer can skip FLS by adding `.systemMode()` and `.withSharing()`.

```apex
// Query executed in without sharing
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.withSharing()
.asList();
```

### without sharing

Developer can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode) and `.withoutSharing()`.

```apex
// Query executed in with sharing
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.withoutSharing()
.asList();
```

### inherited sharing

Developer can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode) by default it is `inherited sharing`.

```apex
// Query executed in inherited sharing
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.asList();
```

## Mocking

TBD

## Avoid duplicates

Generic SOQLs can be keep in selector class.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType).fields(new List<sObjectField>{
                Account.Name,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
        }
    }

    public static QS getByRecordType(String rtDevName) {
        return Selector.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(QS.Condition.recordTypeDeveloperName().equal(rtDevName);
    }

    public static QS getById(Id accountId) {
        return Selector.whereAre(QS.Condition.id().equal(accountId));
    }
}
```

## Default configuration

The selector class can provide default SOQL configuration like default fields, FLS settings, and sharing rules.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{  // default fields
                    Account.Id,
                    Account.Name
                })
                .systemMode(); // default FLS mode
        }
    }
}
```
