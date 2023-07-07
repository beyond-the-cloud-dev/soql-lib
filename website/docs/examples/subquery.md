---
sidebar_position: 4
---

# SUBQUERY

Specify child relationship name and pass list of fields.

```sql
SELECT Id, Name, (
    SELECT Id, Name FROM Contacts
) FROM Account
```
```apex
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return AccountSelector.query()
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
            ).toList();
    }
}
```

SOQL supports relationship queries that traverse up to five levels of parent-child records.

[Query Five Levels of Parent-to-Child Relationships in SOQL Queries](https://help.salesforce.com/s/articleView?id=release-notes.rn_api_soql_5level.htm&release=244&type=5)

```sql
SELECT Name, (
    SELECT LastName , (
        SELECT AssetLevel FROM Assets
    ) FROM Contacts
) FROM Account
```
```apex
public inherited sharing class AccountSelector implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return AccountSelector.query()
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.LastName)
                .with(SOQL.SubQuery.of('Assets')
                    .with(Asset.AssetLevel)
                )
            ).toList();
    }
}
```
