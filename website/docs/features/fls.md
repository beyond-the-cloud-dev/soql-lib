---
sidebar_position: 1
---

# Field-Level Security

[Enforce User Mode for Database Operations](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm)

> Apex code runs in system mode by default, which means that it runs with substantially elevated permissions over the user running the code. To enhance the security context of Apex, you can specify user mode access for database operations. Field-level security (FLS) and object permissions of the running user are respected in user mode, unlike in system mode. User mode always applies sharing rules, but in system mode they’re controlled by sharing keywords on the class

Used methods | Mode | FLS
------------ | ---- | --------------
none (by default) | `USER_MODE` | enforced
`.systemMode()` | `SYSTEM_MODE` | ignored
`.systemMode().stripInaccessible()` | `SYSTEM_MODE` | enforced

## Default

`USER_MODE` is a enabled by default. It means that **the object permissions, field-level security**, sharing rules **are enforced**.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber);
    }
}
```

The object permissions, field-level security, sharing rules are enforced.
Access to `Account` object and fields: `Account.Name`, `Account.AccountNumber` will be checked.

```apex
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

## Customize

### System Mode

Developer can disable `USER_MODE` and enable `SYSTEM_MODE` via `.systemMode()` method.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode();
    }
}
```

The object permissions, field-level permissions are ignored.

```apex
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

### Strip Inaccessible

`USER_MODE` enforced not only object and field-level security, but also sharing rules (`with sharing`).
You can be in the case, where you need object and field-level security, but want to ignore sharing rules (`without sharing`).
To achieve it use `.systemMode()`, `.withoutSharing()` and `.stripInaccessible()`.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withoutSharing()
            .stripInaccessible();
    }
}
```

The object permissions, field-level permissions are forced, but sharing rules are ignored.

```apex
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```
