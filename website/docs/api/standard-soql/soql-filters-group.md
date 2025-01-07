---
sidebar_position: 40
---

# FilterGroup

Create group of conditions.

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(SOQL.Filter.name().equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
    ).toList();
```

## Methods

The following are methods for `FilterGroup`.

[**ADD CONDITION**](#add-condition)

- [`add(FilterGroup filterGroup)`](#add)
- [`add(Filter filter)`](#add)
- [`add(String dynamicCondition)`](#add)

[**ORDER**](#order)

- [`anyConditionMatching()`](#anyconditionmatching)
- [`conditionLogic(String order)`](#conditionlogic)

[**ADDITIONAL**](#additional)

- [`ignoreWhen(Boolean logicExpression)`](#ignorewhen)

## ADD CONDITION
### add

Allows to add multiple conditions.
Add a [`SOQL.Filter`](soql-filter.md) or [`SOQL.FilterGroup`](soql-filters-group.md) or `String`.

**Signature**

```apex
FilterGroup add(FilterGroup filterGroup)
FilterGroup add(Filter filter)
FilterGroup add(String dynamicCondition)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE
    Industry = 'IT' AND
    Name = 'My Account' AND
    NumberOfEmployees >= 10
```

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

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(SOQL.Filter.name().equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
    ).toList();
```

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .add(SOQL.Filter.name().equal('My Account'))
        .add('NumberOfEmployees >= 10')
    ).toList();
```

## ORDER
### conditionLogic

Set conditions order for SOQL query.
When not specify all conditions will be with `AND`.

**Signature**

```apex
FilterGroup conditionLogic(String order)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE (Name = 'My Account' AND NumberOfEmployees >= 10)
OR (Name = 'My Account' AND Industry = 'IT')
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Name).equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    ).toList();
```

### anyConditionMatching

When the [conditionLogic](#conditionlogic) is not specified, all conditions are joined using the `AND` operator by default.

To change the default condition logic, you can utilize the `anyConditionMatching` method, which joins conditions using the `OR` operator.

**Signature**

```apex
FilterGroup anyConditionMatching()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'My Account' OR NumberOfEmployees >= 10
```

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Name).equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
        .anyConditionMatching()
    ).toList();
```

## ADDITIONAL

### ignoreWhen

All group's conditions will be removed when logic expression will evaluate to true.

**Signature**

```apex
FilterGroup ignoreWhen(Boolean logicExpression);
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Industry = 'IT' AND Name LIKE '%MyAccount%'
```

```apex
Boolean isPartnerUser = false;

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
            .add(SOQL.Filter.with(Account.BillingCity).equal('Warsaw'))
            .anyConditionMatching()
            .ignoreWhen(!isPartnerUser)
        )
        .add(SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.Industry).equal('IT'))
            .add(SOQL.Filter.name().contains('MyAcccount'))
        )
    )
    .toList();
```
