---
sidebar_position: 6
---

# WHERE

Use [SOQL.FilterGroup](../api/soql-filters-group.md) and Use [SOQL.Filter](../api/soql-filter.md) to build your `WHERE` clause.

```sql
SELECT Id, Name
FROM Account
WHERE Id = :accountId OR Name LIKE :'%' + accountName + '%'
```
```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query()
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getByIdOrName(Id accountId, String accountName) {
        return SOQL_Account.query()
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.id().equal(accountId))
                .add(SOQL.Filter.name().contains(accountName))
                .anyConditionMatching() // OR
            )
            .toList();
    }
}
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
