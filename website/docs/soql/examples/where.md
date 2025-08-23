---
sidebar_position: 60
---

# WHERE

Use [SOQL.FilterGroup](../api/soql-filters-group.md) and Use [SOQL.Filter](../api/soql-filter.md) to build your `WHERE` clause.

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

**SOQL**

```sql
SELECT Id, Name
FROM Account
WHERE Id = :accountId OR Name LIKE :'%' + accountName + '%'
```

**SOQL Lib**

```apex
SOQL.of(Account.SObject)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Id).equal(account.Id))
        .add(SOQL.Filter.with(Account.Name).contains(accountName))
    )
    .toList();
```

## Single Condition

**SOQL**

```sql
SELECT Id, Name
FROM Account
WHERE Name LIKE :'%' + accountName + '%'
```

**SOQL Lib**

```apex
SOQL.of(Account.SObject)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Name).contains(accountName))
    .toList();
```

## Multiple Conditions

**SOQL**

```sql
SELECT Id
FROM Account
WHERE Industry = 'IT' AND ((Name = 'My Account' AND NumberOfEmployees >= 10)
OR (Name = 'My Account 2' AND NumberOfEmployees <= 20))
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('IT'))
    .whereAre(SOQL.Filter.name().equal('My Account'))
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
    .whereAre(SOQL.Filter.name().equal('My Account 2'))
    .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessOrEqual(20))
    .conditionLogic('1 AND ((2 AND 3) OR (4 AND 5))')
    .toList();

// or

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(SOQL.Filter.name().equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
        .add(SOQL.Filter.name().equal('My Account 2'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).lessOrEqual(20))
        .conditionLogic('1 AND ((2 AND 3) OR (4 AND 5))')
    ).toList();

// or

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(SOQL.FilterGroup
            .add(SOQL.Filter.name().equal('My Account'))
            .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
            .add(SOQL.Filter.name().equal('My Account 2'))
            .add(SOQL.Filter.with(Account.NumberOfEmployees).lessOrEqual(20))
            .conditionLogic('(1 AND 2) OR (3 AND 4)')
        )
    ).toList();

// or

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(SOQL.FilterGroup
            .add(SOQL.FilterGroup
                .add(SOQL.Filter.name().equal('My Account'))
                .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
            )
            .add(SOQL.FilterGroup
                .add(SOQL.Filter.name().equal('My Account 2'))
                .add(SOQL.Filter.with(Account.NumberOfEmployees).lessOrEqual(20))
            )
            .anyConditionMatching()
        )
    ).toList();
```

## Custom Conditions Order

**SOQL**

```sql
SELECT Id
FROM Account
WHERE (Name = 'My Account' AND NumberOfEmployees >= 10)
OR (Name = 'My Account' AND Industry = 'IT')
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.name().equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    ).toList();
```

## Dynamic Conditions

**SOQL**

```sql
SELECT Id
FROM Account
WHERE
    Industry = 'IT' AND
    Name = 'My Account' AND
    NumberOfEmployees >= 10
```

**SOQL Lib**

```apex
// build conditions on fly
SOQL.FilterGroup group = SOQL.FilterGroup
    .add(SOQL.Filter.name().equal('My Account'))
    .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10));

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(group)
    ).toList();
```

## String Conditions

**SOQL**

```sql
SELECT Id
FROM Account
WHERE
    Industry = 'IT' AND
    Name = 'My Account' AND
    NumberOfEmployees >= 10
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .whereAre('Name = \'My Account\' AND NumberOfEmployees >= 10')
    .toList();
```

## Ignore Condition

**SOQL**

```sql
SELECT Id
FROM Account
WHERE BillingCity = 'Krakow'
    AND Name LIKE %accountName%
```

**SOQL Lib**

```apex
String accountName = '';

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
        .add(SOQL.Filter.name().contains(accountName)
            .ignoreWhen(String.isEmpty(accountName)) // <==
        )
    ).toList();
```
