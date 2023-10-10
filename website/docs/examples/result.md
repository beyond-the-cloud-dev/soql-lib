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

    public static Map<Id, Account> getAccountMap() {
        return (Map<Id, Account>) SOQL_Account.query().toMap();
    }

    public static Map<String, Account> getAccountsPerName() {
        return (Map<String, Account>) SOQL_Account.query().toMap(Account.Name);
    }

    public static Map<String, String> getAccountIndustryPerAccountId() {
        return SOQL_Account.query().toMap(Account.Id, Account.Industry);
    }

    public static Map<String, List<Account>> getAccountsPerIndustry() {
        return (Map<String, List<Account>>) SOQL_Account.query().toAggregatedMap(Account.Industry);
    }

    public static Map<String, List<String>> getAccountNamesPerIndustry() {
        return SOQL_Account.query().toAggregatedMap(Account.Industry, Account.Name);
    }

    public static Database.QueryLocator getAccountQueryLocator() {
        return SOQL_Account.query().toQueryLocator();
    }
}
```
