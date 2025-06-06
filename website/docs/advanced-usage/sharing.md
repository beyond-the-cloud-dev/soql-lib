---
sidebar_position: 20
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

`USER_MODE` is a enabled by default. It means that the object permissions, field-level security and **sharing rules are enforced**.

```apex title="SOQL_Account.cls"
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Name, Account.AccountNumber);
    }
}
```

The object permissions, field-level security, and sharing rules are enforced. Class sharing mode is ignored (`without sharing`).

```apex title="ExampleController.cls"
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

## Customize

Developers can control the sharing mode (`inherited sharing`, `with sharing`, and `without sharing`) only in `SYSTEM_MODE`.
`SYSTEM_MODE` can be enabled via the `.systemMode()` method.

### Inherited Sharing

**NOTE!** To make it work, always set `inherited sharing` in your selector class.

```apex title="SOQL_Account.cls"
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Name, Account.AccountNumber)
            .systemMode();
    }
}
```

The object permissions and field-level permissions are ignored. Sharing rules are controlled by the sharing mode (`without sharing`).

```apex title="ExampleController.cls"
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

### With Sharing

You can force the sharing mode for all of your queries.

```apex title="SOQL_Account.cls"
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withSharing();
    }
}
```

The object permissions and field-level permissions are ignored. Sharing rules are controlled by the sharing mode specified in the `query()` method (`.withSharing()`).

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```


### Without Sharing

You can force the sharing mode for all of your queries.

```apex title="SOQL_Account.cls"
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withoutSharing();
    }
}
```

The object permissions and field-level permissions are ignored. Sharing rules are controlled by the sharing mode specified in the `query()` method (`.withoutSharing()`).

```apex title="ExampleController.cls"
public with sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```
