---
sidebar_position: 25
---

# TypeOf

Construct `TYPEOF` expression with provided API.

```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Phone, Account.NumberOfEmployees)
        .whenElse('Name')
    )
    .toList();
```

## Methods

The following are methods for `TypeOf`.

[**INIT**](#init)

- [`of(String ofField)`](#of)
- [`of(SObjectField ofField)`](#of)

[**WHEN**](#when)

- [`when(SObjectType whenObject)`](#when-object)

[**THEN**](#then)

- [`then(SObjectField field)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2, SObjectField field3)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#then-field1---field5)
- [`then(List<SObjectField> fields)`](#then-fields)
- [`then(Iterable<String> fields)`](#then-string-fields)
- [`then(String fields)`](#then-string-fields)
- [`then(String relationshipName, SObjectField field)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field1, SObjectField field2)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#then-related-field1---field5)
- [`then(String relationshipName, Iterable<SObjectField> fields)`](#then-related-fields)

[**ELSE**](#else)

- [`whenElse(Iterable<String> fields)`](#else-fields)
- [`whenElse(String fields)`](#else-fields)

## INIT
### of

Constructs a `TypeOf` for a polymorphic relationship field. Pass the lookup field (`Event.WhatId`) or the relationship name (`'What'`).

**Signature**

```apex
TypeOf of(String ofField)
```
```apex
TypeOf of(SObjectField ofField)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Account THEN Phone
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Phone)
    )
    .toList();
```

## WHEN

### when object

Starts a `WHEN` branch for the object type. The following `then` methods add fields to that branch.

**Signature**

```apex
TypeOf when(SObjectType whenObject)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Account THEN Phone, NumberOfEmployees
    WHEN Opportunity THEN Amount, CloseDate
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Phone, Account.NumberOfEmployees)
        .when(Opportunity.SObjectType)
        .then(Opportunity.Amount, Opportunity.CloseDate)
    )
    .toList();
```

## THEN

### then field1 - field5

**Signature**

```apex
TypeOf then(SObjectField field)
```
```apex
TypeOf then(SObjectField field1, SObjectField field2)
```
```apex
TypeOf then(SObjectField field1, SObjectField field2, SObjectField field3)
```
```apex
TypeOf then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)
```
```apex
TypeOf then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Account THEN Id, Name, Phone
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Id, Account.Name, Account.Phone)
    )
    .toList();
```

### then fields

Use for more than 5 fields.

**Signature**

```apex
TypeOf then(List<SObjectField> fields)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Account THEN Id, Name, Phone, Industry, BillingCity, BillingCountry
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(new List<SObjectField>{
            Account.Id,
            Account.Name,
            Account.Phone,
            Account.Industry,
            Account.BillingCity,
            Account.BillingCountry
        })
    )
    .toList();
```

### then string fields

**NOTE!** With String Apex does not create reference to field. Use `SObjectField` whenever it possible. Method below should be only use for dynamic queries.

**Signature**

```apex
TypeOf then(Iterable<String> fields)
```
```apex
TypeOf then(String fields)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Account THEN Id, Name, Owner.Name
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then('Id, Name, Owner.Name')
    )
    .toList();
```

### then related field1 - field5

Allows to add parent field.

**Signature**

```apex
TypeOf then(String relationshipName, SObjectField field)
```
```apex
TypeOf then(String relationshipName, SObjectField field1, SObjectField field2)
```
```apex
TypeOf then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3)
```
```apex
TypeOf then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)
```
```apex
TypeOf then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Opportunity THEN Account.Id, Account.Name
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Opportunity.SObjectType)
        .then('Account', Account.Id, Account.Name)
    )
    .toList();
```

### then related fields

Allows to add parent fields.

Use for more than 5 parent fields.

**Signature**

```apex
TypeOf then(String relationshipName, Iterable<SObjectField> fields)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Opportunity THEN Account.Id, Account.Name, Account.Phone, Account.Industry, Account.BillingCity, Account.BillingCountry
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Opportunity.SObjectType)
        .then('Account', new List<SObjectField>{
            Account.Id,
            Account.Name,
            Account.Phone,
            Account.Industry,
            Account.BillingCity,
            Account.BillingCountry
        })
    )
    .toList();
```

## ELSE

### else fields

Fields returned when no `WHEN` branch matches. Salesforce allows only fields of the `Name` object here, e.g. `Name`, `Email`, `Phone`.

**Signature**

```apex
TypeOf whenElse(Iterable<String> fields)
```
```apex
TypeOf whenElse(String fields)
```

**Example**

```sql
SELECT TYPEOF What
    WHEN Account THEN Phone
    ELSE Name, Email
END
FROM Event
```
```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Phone)
        .whenElse('Name, Email')
    )
    .toList();
```
