---
sidebar_position: 6
---

# WHERE

Use [SOQL.FilterGroup](../api/soql-filters-group.md) and Use [SOQL.Filter](../api/soql-filter.md) to build your `WHERE` clause.

Define basic filters in your Selector class.

```sql
SELECT Id, Name
FROM Account
WHERE Id = :accountId OR Name LIKE :'%' + accountName + '%'
```
```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Id, Account.Name);
    }

    public SOQL_Account byRecordType(String rt) {
        whereAre(Filter.recordType().equal(rt));
        return this;
    }

    public SOQL_Account byIndustry(String industry) {
        with(Account.Industry)
            .whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        with(Account.ParentId)
            .whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }
}

public with sharing class MyController {

    @AuraEnabled
    public static List<Account> getAccountsByRecordType(String recordType) {
        return SOQL_Account.query()
            .byRecordType(recordType)
            .byIndustry('IT')
            .with(Account.Industry, Account.AccountSource)
            .toList();
    }

    @AuraEnabled
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
