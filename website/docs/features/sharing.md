---
sidebar_position: 3
---

# Sharing Rules

[Enforce User Mode for Database Operations](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm)

> Apex code runs in system mode by default, which means that it runs with substantially elevated permissions over the user running the code. To enhance the security context of Apex, you can specify user mode access for database operations. Field-level security (FLS) and object permissions of the running user are respected in user mode, unlike in system mode. User mode always applies sharing rules, but in system mode they’re controlled by sharing keywords on the class

Used methods | Mode | Sharing Mode
------------ | ---- | --------------
none (by default) | `USER_MODE` | `with sharing`
`.systemMode()` | `SYSTEM_MODE` | `inherited sharing`
`.systemMode().withoutSharing()` | `SYSTEM_MODE` | `without sharing`
`.systemMode().withSharing()` | `SYSTEM_MODE` | `with sharing`

## Default

`USER_MODE` is a enabled by default. It means that the object permissions, field-level security, **sharing rules are enforced**.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber);
    }
}
```

The object permissions, field-level security, sharing rules are enforced. Class sharing mode is ignored (`without sharing`).

```apex
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

## Customize

Developer can control sharing mode: `inherited sharing`, `with sharing` and `without sharing` only in the `SYSTEM_MODE`.
`SYSTEM_MODE` can be enabled via `.systemMode()` method.

### Inherited Sharing

**NOTE!** To make it working always set `inherited sharing` in your selector class.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode();
    }
}
```

The object permissions, field-level permissions are ignored, sharing rules are controlled by the sharing mode (`without sharing`).

```apex
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

### With Sharing

You can force sharing mode to all of your queries.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withSharing();
    }
}
```

The object permissions, field-level permissions are ignored, sharing rules are controlled by the sharing mode specified in `query()` method (`.withSharing()`).

```apex
public with sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```


### Without Sharing

You can force sharing mode to all of your queries.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withoutSharing();
    }
}
```

The object permissions, field-level permissions are ignored, sharing rules are controlled by the sharing mode specified in `query()` method (`.withoutSharing()`).

```apex
public with sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```
