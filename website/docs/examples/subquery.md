---
sidebar_position: 4
---

# SUBQUERY

Specify child relationship name and pass list of fields.

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return (List<Account>) AccountSelector.Query
            .subQuery(SOQL.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id,
                    Contact.Name
                })
            ).asList();
    }
}
```
