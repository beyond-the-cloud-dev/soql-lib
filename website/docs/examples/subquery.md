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
            .with(new List<SObjectField>{
                Account.Id,
                Account.Name
            });
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return AccountSelector.query()
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id,
                    Contact.Name
                })
            ).toList();
    }
}
```
