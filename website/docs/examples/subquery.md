---
sidebar_position: 4
---

# SUBQUERY

Specify child relationship name and pass list of fields.

```apex
public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType)
                .fields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccountsWithContacts() {
        return (List<Account>) QS_Account.Selector
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id,
                    Contact.Name
                })
            ).asList();
    }
}
```
