---
sidebar_position: 4
---

# SUBQUERY

For more details check Check [SOQL API - SubQuery](../../api/standard-soql/soql-sub.md).

**SOQL**

```sql
SELECT Id, Name, (
    SELECT Id, Name FROM Contacts
) FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Id, Contact.Name)
    )
    .toList();
```

## Fields

### SObjectField Fields (Recommended)

**SOQL**

```sql
SELECT Id, Name, (
    SELECT Id, Name FROM Contacts
) FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Id, Contact.Name)
    )
    .toList();
```

### String Fields

**SOQL**

```sql
SELECT Id, Name, (
    SELECT Id, Name FROM Contacts
) FROM Account
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with(SOQL.SubQuery.of('Contacts')
        .with('Id, Name')
    )
    .toList();
```

## Parent Fields

**SOQL**

```sql
SELECT Id, Name, (
    SELECT Id, Name, CreatedBy.Id, CreatedBy.Name
    FROM Contacts
) FROM Account
```

**SOQL Lib**

```sql
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.Id, Contact.Name)
        .with('CreatedBy', new List<SObjectField>{
            User.Id, User.Name
        })
    )
    .toList();
```

## Nested SubQuery

SOQL supports relationship queries that traverse up to five levels of parent-child records. [Query Five Levels of Parent-to-Child Relationships in SOQL Queries](https://help.salesforce.com/s/articleView?id=release-notes.rn_api_soql_5level.htm&release=244&type=5).

**SOQL**

```sql
SELECT Id, Name, (
    SELECT FirstName, LastName , (
        SELECT Id, AssetLevel FROM Assets
    ) FROM Contacts
) FROM Account
```

**SOQL Lib**

```apex
SOQL_Account.query()
    .with(Account.Id, Account.Name)
    .with(SOQL.SubQuery.of('Contacts')
        .with(Contact.FirstName, Contact.LastName)
        .with(SOQL.SubQuery.of('Assets')
            .with(Asset.Id, Asset.AssetLevel)
        )
    ).toList();
```
