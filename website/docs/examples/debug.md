---
sidebar_position: 14
---

# Debug

See query String in debug logs.

```apex
public inherited sharing class AccountSelector {

    public static SOQL query {
        get {
            return SOQL.of(Account.SObjectType)
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return AccountSelector.query
            .with(new List<SObjectField>{
                Account.BillingCity,
                Account.BillingCountry,
                Account.BillingCountryCode
            })
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Id).equal('0013V00000WNCw4QAH'))
                .add(SOQL.Filter.with(Account.Name).contains('Test'))
                .conditionLogic('1 OR 2')
             )
            .preview()
            .toList();
    }
}
```

You will see in debug logs:

```
============ Query Preview ============
SELECT Name, AccountNumber, BillingCity, BillingCountry, BillingCountryCode
FROM Account
WHERE (Id = :v1 OR Name LIKE :v2)
=======================================

============ Query Binding ============
{
  "v2" : "%Test%",
  "v1" : "0013V00000WNCw4QAH"
}
=======================================
```
