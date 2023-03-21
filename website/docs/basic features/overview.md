---
sidebar_position: 1
---

# Overview

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

By default all queries are in `AccessLevel.USER_MODE`.

> The object permissions, field-level security, and sharing rules of the current user are enforced.

Developer can change it by using `.systemMode()` = `AccessLevel.SYSTEM_MODE`.

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

By default all queries will be executed `with sharing`, because of `AccessLevel.USER_MODE` which enforce also sharing rules.

Developer can control sharing rules by adding `.systemMode()` (record sharing rules are controlled by the sharingMode) and `.withSharing()`/`.withoutSharing()`.

```apex
// Query executed in inherited sharing
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.asList();
```

```apex
// Query executed in with sharing
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.withSharing()
.asList();
```

```apex
// Query executed in without sharing
QS.of(Account.sObjectType).fields(new List<sObjectField> {
    Account.Id, Account.Name
})
.systemMode()
.withoutSharing()
.asList();
```
