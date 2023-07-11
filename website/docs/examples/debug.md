---
sidebar_position: 14
---

# Debug

See query String in debug logs.

```apex
public inherited sharing class SOQL_Account implements SOQL.Selector {

    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static List<Account> getAccounts() {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry, Account.BillingCountryCode)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.id().equal('0013V00000WNCw4QAH'))
                .add(SOQL.Filter.name().contains('Test'))
                .anyConditionMatching()
             )
            .preview()
            .toList();
    }
}
```

You will see in debug logs:

```
============ Query Preview ============
SELECT Id, Name, BillingCity, BillingCountry, BillingCountryCode
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
