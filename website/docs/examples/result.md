---
sidebar_position: 15
---

# RESULT

Execut SOQL and get results.

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Id, Account.Name);
    }
}

public with sharing class MyController {

    public static String getAccountName(Id accountId) {
        return (String) SOQL_Account.query().byId(accountId).toValueOf(Account.Name);
    }

    public static Set<String> getAccountIndustries() {
        return SOQL_Account.query().toValuesOf(Account.Industry);
    }

    public static Account getAccountById(Id accountId) {
        return (Account) SOQL_Account.query().byId(accountId).toObject();
    }

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return SOQL_Account.query().byIds(accountIds).toList();
    }

    public static List<AggregateResult> getUniqueAccountNameAmount() {
        return SOQL_Account.query().count(Account.Name, 'names').toAggregated();
    }

    public static Integer countAccounts() {
        return SOQL_Account.query().count().toInteger();
    }

    public static Map<Id, SObject> getAccountMap() {
        return SOQL_Account.query().toMap();
    }

    public static Database.QueryLocator getAccountQueryLocator() {
        return SOQL_Account.query().toQueryLocator();
    }
}
```
