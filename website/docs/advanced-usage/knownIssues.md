---
sidebar_position: 40
---

import Availability from '@site/src/components/Availability';

# Known Issues

<Availability
  modules={['SOQL']}
></Availability>

## Variable does not exist

Error: `System.QueryException: Variable does not exist: v1`

### Root Cause

This is **NOT** a SOQL Lib issue but rather a Salesforce platform limitation that occurs when `Database.getQueryLocatorWithBinds` is used with insufficient field-level security permissions.

This error occurs when all of the following conditions are met:
- `toQueryLocator()` method is executed
- Query is executed with `USER_MODE` (which is the default access level if not otherwise specified)
- Query contains fields to which the current user lacks read access permissions
- Query includes at least one WHERE condition, resulting in a non-empty binding map
- The Salesforce platform fails to validate field access permissions before processing bound variables

**Example that fails:**

**Native Apex**

```apex
Database.getQueryLocatorWithBinds(
    'SELECT Type FROM Task WHERE Type != :v1', 
    new Map<String, Object>{'v1' => null}, 
    AccessLevel.USER_MODE
);
```

**SOQL Lib**

```apex
SOQL.of(Task.SObjectType)
    .with(Task.Type) // <== User lacks read access to this field
    .whereAre(SOQL.Filter.with(Task.Type).isNotNull())
    .toQueryLocator();
```

### Technical Context

The error occurs because Salesforce's `Database.getQueryLocatorWithBinds` method attempts to validate bound variables before performing field-level security checks. When the user lacks access to fields referenced in the query, the platform cannot properly resolve the bound variables, resulting in the misleading "Variable does not exist" error message instead of a more accurate field access permission error.

### Solutions

#### Option 1: Grant Field Access Permissions

Grant the current user appropriate field-level security permissions for all fields referenced in the query through:

- **Profile Settings**: Update the user's profile to include read access to the required fields
- **Permission Sets**: Assign permission sets that grant access to the necessary fields
- **Field-Level Security**: Configure field-level security settings for the specific fields

#### Option 2: Use SYSTEM_MODE

Execute the query with elevated permissions using `SYSTEM_MODE` to bypass field-level security restrictions:

**Native Apex**

```apex
Database.getQueryLocatorWithBinds(
    'SELECT Type FROM Task WHERE Type != :v1', 
    new Map<String, Object>{'v1' => null}, 
    AccessLevel.SYSTEM_MODE
);
```

**SOQL Lib**

```apex
SOQL.of(Task.SObjectType)
    .with(Task.Type) 
    .whereAre(SOQL.Filter.with(Task.Type).isNotNull())
    .systemMode() // <== Bypasses field-level security
    .toQueryLocator();
```

**Security Consideration**: Use `SYSTEM_MODE` judiciously as it bypasses security controls and may expose sensitive data to unauthorized users.

## Variable does not exist: SObjectType

Error: `Error: Variable does not exist: SObjectType`

### Root Cause

This error occurs due to Apex variable name conflicts when a local variable name matches the SObjectType class name used in the SOQL query. Apex's compiler becomes confused between the local variable reference and the SObjectType static reference, leading to compilation errors.

**Example that fails:**

```apex
Contact contact = new Contact(FirstName = 'Test', LastName = 'Test');

List<Contact> contacts = SOQL.of(Contact.SObjectType) // <== Conflict with 'contact' variable
    .with(Contact.Id, Contact.Name)
    .setLimit(10)
    .toList();
```

### Technical Context

In Apex, when you declare a variable with the same name as an SObjectType (e.g., `Contact contact`), the compiler prioritizes the local variable scope over the static class reference. This causes `Contact.SObjectType` to be interpreted as attempting to access a property on the local `contact` variable rather than the static `Contact` class, resulting in the compilation error.

### Solution

#### Use Distinct Variable Names

Ensure local variable names are distinct from SObjectType class names to avoid namespace conflicts:

**Example that works:**

```apex
Contact contactRecord = new Contact(FirstName = 'Test', LastName = 'Test');

List<Contact> contacts = SOQL.of(Contact.SObjectType)
    .with(Contact.Id, Contact.Name)
    .setLimit(10)
    .toList();
```

## Method does not exist or incorrect signature: void of(Schema.SObjectField)

Error: `Error: Method does not exist or incorrect signature: void of(Schema.SObjectField) from the type SOQL`

### Root Cause

This error occurs due to **Salesforce's incomplete SObjectType implementation** for certain system objects. The issue stems from Salesforce's internal architecture where certain objects are treated as "pseudo-SObjects" that don't fully implement the standard SObject interface, leading to missing or incomplete method signatures.

### Technical Context

**Primary Object Affected:**

- RecordType

**Example that fails:**

```apex
SOQL.of(RecordType.SObjectType)
    .setLimit(1)
    .toObject();
```

### Solution

#### Use String API Name Instead of SObjectType

Use `SOQL.of('RecordType')` with the string API name instead of using the SObjectType reference.

**Example that works:**

```apex
SOQL.of('RecordType')
    .setLimit(1)
    .toObject();
```