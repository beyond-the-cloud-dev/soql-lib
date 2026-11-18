---
sidebar_position: 45
---

# TYPEOF

For more details check [SOQL API - TypeOf](../api/soql-typeof.md).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.


**SOQL**

```sql
SELECT TYPEOF What
    WHEN Account THEN Phone, NumberOfEmployees
    WHEN Opportunity THEN Amount, CloseDate
    ELSE Name, Email
END
FROM Event
```

**SOQL Lib**

```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Phone, Account.NumberOfEmployees)
        .when(Opportunity.SObjectType)
        .then(Opportunity.Amount, Opportunity.CloseDate)
        .whenElse('Name, Email')
    )
    .toList();
```

## Fields

### SObjectField Fields (Recommended)

**SOQL**

```sql
SELECT Subject, TYPEOF What
    WHEN Account THEN Name, Phone
END
FROM Event
```

**SOQL Lib**

```apex
SOQL.of(Event.SObjectType)
    .with(Event.Subject)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Name, Account.Phone)
    )
    .toList();
```

### String Fields

**SOQL**

```sql
SELECT Subject, TYPEOF What
    WHEN Account THEN Name, Phone
END
FROM Event
```

**SOQL Lib**

```apex
SOQL.of(Event.SObjectType)
    .with(Event.Subject)
    .with(SOQL.TypeOf.of('What')
        .when(Account.SObjectType)
        .then('Name, Phone')
    )
    .toList();
```

## Parent Fields

**SOQL**

```sql
SELECT TYPEOF What
    WHEN Opportunity THEN Name, Account.Name, Account.Phone
END
FROM Event
```

**SOQL Lib**

```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Opportunity.SObjectType)
        .then(Opportunity.Name)
        .then('Account', Account.Name, Account.Phone)
    )
    .toList();
```

## Multiple TYPEOF

**SOQL**

```sql
SELECT
    TYPEOF What
        WHEN Account THEN Name
    END,
    TYPEOF Who
        WHEN Contact THEN Email
    END
FROM Event
```

**SOQL Lib**

```apex
SOQL.of(Event.SObjectType)
    .with(SOQL.TypeOf.of(Event.WhatId)
        .when(Account.SObjectType)
        .then(Account.Name)
    )
    .with(SOQL.TypeOf.of(Event.WhoId)
        .when(Contact.SObjectType)
        .then(Contact.Email)
    )
    .toList();
```
