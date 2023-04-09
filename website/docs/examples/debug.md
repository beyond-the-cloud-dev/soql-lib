---
sidebar_position: 14
---

# Debug

```apex
public inherited sharing class AccountSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType)
                .with(new List<SObjectField>{
                    Account.Id,
                    Account.Name
                });
        }
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return AccountSelector.Query
            .with(new List<SObjectField>{
                Account.BillingCity,
                Account.BillingCountry,
                Account.BillingCountryCode
            })
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Id).equal('0013V00000WNCw4QAH'))
                .add(SOQL.Filter.with(Account.Name).likeAny('Test'))
                .conditionLogic('1 OR 2')
             )
            .preview()
            .asList();
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
