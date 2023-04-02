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
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .with(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return AccountSelector.Query
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<sObjectField>{
                    Contact.Id,
                    Contact.Name
                })
            ).asList();
    }
}
```
