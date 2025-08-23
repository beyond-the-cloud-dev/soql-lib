---
sidebar_position: 150
---

# RESULT

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## toId

**Apex**

```apex title="Traditional Approach"
Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Id accountId = SOQL.of(Account.SObjectType).setLimit(1).toId();
```

## toIds

**Apex**

```apex title="Traditional Approach"
Set<Id> accountIds = new Set<Id>();

for (Account acc : [SELECT Id FROM Account WHERE Industry = 'Technology']) {
    accountIds.add(acc.Id);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Set<Id> accountIds = SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .toIds();
```

## toIdsOf

**Apex**

```apex title="Traditional Approach"
Set<Id> ownerIds = new Set<Id>();

for (Account acc : [SELECT OwnerId FROM Account WHERE Industry = 'Technology']) {
    ownerIds.add(acc.OwnerId);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Set<Id> ownerIds = SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .toIdsOf(Account.OwnerId);
```

## toIdsOf related field

**Apex**

```apex title="Traditional Approach"
Set<Id> parentAccountIds = new Set<Id>();

for (Account acc : [SELECT Parent.Id FROM Account WHERE Industry = 'Technology']) {
    parentAccountIds.add(acc.Parent.Id);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Set<Id> parentAccountIds = SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
    .toIdsOf('Parent', Account.Id);
```

## doExist

**Apex**

```apex title="Traditional Approach"
Integer accountsWithMoreThan100Employees = [
    SELECT COUNT()
    FROM Account
    WHERE NumberOfEmployees > 100
];

Boolean hasAccountsWithMoreThan100Employees = accountsWithMoreThan100Employees > 0;
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Boolean hasAccountsWithMoreThan100Employees = SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter(Account.NumberOfEmployees).greaterThan(100))
    .doExist();
```

## toValueOf

**Apex**

```apex title="Traditional Approach"
String accountName = [SELECT Name FROM Account WHERE Id = '1234'].Name;
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
String accountName = (String) SOQL.of(Account.SObjectType)
    .byId('1234')
    .toValueOf(Account.Name);
```

## toValuesOf

**Apex**

```apex title="Traditional Approach"
Set<String> accountNames = new Set<String>();

for (Account acc : [SELECT Name FROM Account]) {
    accountNames.add(acc.Name);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Set<String> accountNames = SOQL.of(Account.SObjectType)
    .toValuesOf(Account.Name);
```

## toValuesOf related field

**Apex**

```apex title="Traditional Approach"
Set<String> parentAccountNames = new Set<String>();

for (Account acc : [SELECT Name, Parent.Name FROM Account]) {
    parentAccountNames.add(acc.Parent.Name);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Set<String> parentAccountNames = SOQL.of(Account.SObjectType)
    .toValuesOf('Parent', Account.Name);
```

## toInteger

**Apex**

```apex title="Traditional Approach"
Integer amountOfExistingAccounts = [SELECT COUNT() FROM Account];
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Integer amountOfExistingAccounts = SOQL.of(Account.SObjectType).toInteger();
```

## toObject

**Apex**

```apex title="Traditional Approach"
Account account = [
    SELECT Id, Name
    FROM Account
    WHERE Id = '1234'
];
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Account account = (Account) SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .byId('1234')
    .toObject();
```

## toList

**Apex**

```apex title="Traditional Approach"
Account account = [SELECT Id, Name FROM Account];
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
List<Account> accounts = SOQL.of(Account.SObjectType).with(Account.Id, Account.Name).toList();
```

## toAggregated

**Apex**

```apex title="Traditional Approach"
List<AggregateResult> result = [
    SELECT LeadSource
    FROM Lead
    GROUP BY LeadSource
];
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
List<AggregateResult> result = SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .toAggregated();
```

## toMap

**Apex**

```apex title="Traditional Approach"
Map<Id, Account> idToAccount = new Map<Id, Account>([SELECT Id FROM Account]);
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<Id, Account> idToAccount = (Map<Id, Account>) SOQL.of(Account.SObjectType).toMap();
```

## toMap with custom key

**Apex**

```apex title="Traditional Approach"
Map<String, Account> nameToAccount = new Map<String, Account>();

for (Account acc : [SELECT Id, Name FROM Account]) {
    nameToAccount.put(acc.Name, acc);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<String, Account> nameToAccount = (Map<String, Account>) SOQL.of(Account.SObjectType)
    .toMap(Account.Name);
```

## toMap with custom relationship key

**Apex**

```apex title="Traditional Approach"
Map<String, Account> parentCreatedByEmailToAccount = new Map<String, Account>();

for (Account acc : [SELECT Id, Parent.CreatedBy.Email FROM Account]) {
    parentCreatedByEmailToAccount.put(acc.Parent.CreatedBy.Email, acc);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<String, Account> parentCreatedByEmailToAccount = (Map<String, Account>) SOQL.of(Account.SObjectType)
    .toMap('Parent.CreatedBy', User.Email);
```

## toMap with custom key and value

**Apex**

```apex title="Traditional Approach"
Map<String, String> accountNameToIndustry = new Map<String, String>();

for (Account acc : [SELECT Id, Name, Industry FROM Account]) {
    accountNameToIndustry.put(acc.Name, acc.Industry);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<String, String> accountNameToIndustry = SOQL.of(Account.SObjectType)
    .toMap(Account.Name, Account.Industry);
```

## toAggregatedMap

**Apex**

```apex title="Traditional Approach"
Map<String, List<Account>> industryToAccounts = new Map<String, List<Account>>();

for (Account acc : [SELECT Id, Name, Industry FROM Account]) {
    if (!industryToAccounts.containsKey(acc.Industry)) {
        industryToAccounts.put(acc.Industry, new List<Acccount>());
    }

    industryToAccounts.get(acc.Industry).put(acc);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<String, List<Account>> industryToAccounts = (Map<String, List<Account>>) SOQL.of(Account.SObjectType)
    .toAggregatedMap(Account.Industry);
```

## toAggregatedMap with relationship key

**Apex**

```apex title="Traditional Approach"
Map<String, List<Account>> parentCreatedByEmailToAccounts = new Map<String, List<Account>>();

for (Account acc : [SELECT Id, Name, Parent.CreatedBy.Email FROM Account]) {
    if (!parentCreatedByEmailToAccounts.containsKey(acc.Parent.CreatedBy.Email)) {
        parentCreatedByEmailToAccounts.put(acc.Parent.CreatedBy.Email, new List<Account>());
    }

    parentCreatedByEmailToAccounts.get(acc.Parent.CreatedBy.Email).put(acc);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<String, List<Account>> parentCreatedByEmailToAccounts = (Map<String, List<Account>>) SOQL.of(Account.SObjectType)
    .toAggregatedMap('Parent.CreatedBy', User.Email);
```

## toAggregatedMap with custom key and value

**Apex**

```apex title="Traditional Approach"
Map<String, List<Account>> accountNamesByIndustry = new Map<String, List<String>>();

for (Account acc : [SELECT Id, Name, Industry FROM Account]) {
    if (!accountNamesByIndustry.containsKey(acc.Industry)) {
        accountNamesByIndustry.put(acc.Industry, new List<String>());
    }

    accountNamesByIndustry.get(acc.Industry).put(acc.Name);
}
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Map<String, List<String>> accountNamesByIndustry = SOQL.of(Account.SObjectType)
    .toAggregatedMap(Account.Industry, Account.Name);
```

## toQueryLocator

**Apex**

```apex title="Traditional Approach"
Database.QueryLocator queryLocator = Database.getQueryLocator('SELECT Id FROM ACCOUNT');
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
Database.QueryLocator queryLocator = SOQL.of(Account.SObjectType).toQueryLocator();
```
