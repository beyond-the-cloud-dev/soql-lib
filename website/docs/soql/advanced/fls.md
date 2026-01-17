---
sidebar_position: 10
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

`USER_MODE` is enabled by default. It means that **the object permissions, field-level security**, as well as sharing rules, **are enforced**.

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

The object permissions, field-level security, and sharing rules are enforced.
Access to the `Account` object and fields (`Account.Name` and `Account.AccountNumber`) will be checked.

```apex title="ExampleController.cls"
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

## Customize

### System Mode

Developers can disable `USER_MODE` and enable `SYSTEM_MODE` using the `.systemMode()` method.

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

The object permissions and field-level permissions are ignored.

```apex title="ExampleController.cls"
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```

### Strip Inaccessible

`USER_MODE` enforces not only object and field-level security but also sharing rules (`with sharing`).
You may encounter situations where you need object and field-level security but want to ignore sharing rules (`without sharing`).
To achieve this, use `.systemMode()`, `.withoutSharing()` and `.stripInaccessible()`.

```apex title="SOQL_Account.cls"
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withoutSharing()
            .stripInaccessible();
    }
}
```

The object permissions and field-level permissions are enforced, but sharing rules are ignored.

```apex title="ExampleController.cls"
public without sharing class ExampleController {
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query().toList();
    }
}
```
