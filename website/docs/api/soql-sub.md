---
sidebar_position: 2
---

# SubQuery

## of

Conctructs an `SOQL`.

**Signature**

```apex
SubQuery of(sObjectType ofObject)
```

**Example**

```apex
//SELECT Id, (SELECT Id FROM Contacts) FROM Account
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts'))
    .asList();
```

## select

### with fields

**Signature**

```apex
SubQuery with(List<sObjectField> fields)
```


**Example**

```apex
//SELECT Id, (SELECT Id, Name FROM Contacts) FROM Account
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(new List<sObjectField>{
            Contact.Id, Contact.Name
        })
    )
    .asList();
```

### with related fields

**Signature**

```apex
SubQuery with(String relationshipName, List<sObjectField> fields)
```


**Example**

```apex
//SELECT Id, (SELECT CreatedBy.Id, CreatedBy.Name FROM Contacts) FROM Account
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with('CreatedBy',
            User.Id, User.Name
        })
    )
    .asList();
```
