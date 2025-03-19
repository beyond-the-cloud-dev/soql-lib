---
sidebar_position: 6
---

# WHERE

Use [SOQL.FilterGroup](../../api/standard-soql/soql-filters-group.md) and Use [SOQL.Filter](../../api/standard-soql/soql-filter.md) to build your `WHERE` clause.

Define basic filters in your Selector class.

```sql
SELECT Id, Name
FROM Account
WHERE Id = :accountId OR Name LIKE :'%' + accountName + '%'
```
```apex
SOQL.of(Account.SObject)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Id).equal(account.Id))
        .add(SOQL.Filter.with(Account.Name).contains(accountName))
    )
```

## Custom Order

```sql
SELECT Id
FROM Account
WHERE (Name = 'My Account' AND NumberOfEmployees >= 10)
OR (Name = 'My Account' AND Industry = 'IT')
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.name().equal('My Account'))
        .add(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10))
        .add(SOQL.Filter.with(Account.Industry).equal('IT'))
        .conditionLogic('(1 AND 2) OR (1 AND 3)')
    ).toList();
```

## Dynamic Filters

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
