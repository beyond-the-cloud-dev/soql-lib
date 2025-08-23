---
sidebar_position: 10
---

# RESULT

For more details check [SOQLEvaluator API - RESULT](../../api/soql-evaluator/soql-evaluator.md#result).

## toId

**Apex**

```apex
List<Account> accounts = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
Id accountId = accounts.isEmpty() ? null : accounts[0].Id;
```

**SOQL Lib**

```apex
Id accountId = SOQLEvaluator.of([
    SELECT Id 
    FROM Account 
    WITH USER_MODE
    LIMIT 1
]).toId();
```

## toIds

**Apex**

```apex
Set<Id> accountIds = new Set<Id>();

for (Account acc : [SELECT Id FROM Account WHERE Industry = 'Technology' WITH USER_MODE]) {
    accountIds.add(acc.Id);
}
```

**SOQL Lib**

```apex
Set<Id> accountIds = SOQLEvaluator.of([
    SELECT Id 
    FROM Account 
    WHERE Industry = 'Technology'
    WITH USER_MODE
]).toIds();
```

## toIdsOf

**Apex**

```apex
Set<Id> ownerIds = new Set<Id>();

for (Account acc : [SELECT OwnerId FROM Account WHERE Industry = 'Technology' WITH USER_MODE]) {
    if (acc.OwnerId != null) {
        ownerIds.add(acc.OwnerId);
    }
}
```

**SOQL Lib**

```apex
Set<Id> ownerIds = SOQLEvaluator.of([
    SELECT OwnerId 
    FROM Account 
    WHERE Industry = 'Technology'
    WITH USER_MODE
]).toIdsOf(Account.OwnerId);
```

## toIdsOf related field

**Apex**

```apex
Set<Id> parentAccountIds = new Set<Id>();

for (Account acc : [SELECT Parent.Id FROM Account WHERE Industry = 'Technology' WITH USER_MODE]) {
    if (acc.Parent?.Id != null) {
        parentAccountIds.add(acc.Parent.Id);
    }
}
```

**SOQL Lib**

```apex
Set<Id> parentAccountIds = SOQLEvaluator.of([
    SELECT Parent.Id 
    FROM Account 
    WHERE Industry = 'Technology'
    WITH USER_MODE
]).toIdsOf('Parent', Account.Id);
```

## doExist

**Apex**

```apex
List<Account> accounts = [
    SELECT Id
    FROM Account 
    WHERE NumberOfEmployees > 100
    WITH USER_MODE
    LIMIT 1
];

Boolean hasAccountsWithMoreThan100Employees = !accounts.isEmpty();
```

**SOQL Lib**

```apex
Boolean hasAccountsWithMoreThan100Employees = SOQLEvaluator.of([
    SELECT Id
    FROM Account 
    WHERE NumberOfEmployees > 100
    WITH USER_MODE
]).doExist();
```

## toValueOf

**Apex**

```apex
List<Account> accounts = [SELECT Name FROM Account WHERE Id = '1234' WITH USER_MODE LIMIT 1];
String accountName = accounts.isEmpty() ? null : accounts[0].Name;
```

**SOQL Lib**

```apex
String accountName = (String) SOQLEvaluator.of([
    SELECT Name 
    FROM Account 
    WHERE Id = '1234'
    WITH USER_MODE
    LIMIT 1
]).toValueOf(Account.Name);
```

## toValuesOf

**Apex**

```apex
Set<String> accountNames = new Set<String>();

for (Account acc : [SELECT Name FROM Account WITH USER_MODE]) {
    if (acc.Name != null) {
        accountNames.add(acc.Name);
    }
}
```

**SOQL Lib**

```apex
Set<String> accountNames = SOQLEvaluator.of([
    SELECT Name 
    FROM Account
    WITH USER_MODE
]).toValuesOf(Account.Name);
```

## toObject

**Apex**

```apex
List<Account> accounts = [
    SELECT Id, Name
    FROM Account
    WHERE Id = '1234'
    WITH USER_MODE
    LIMIT 1
];

Account account = accounts.isEmpty() ? null : accounts[0];
```

**SOQL Lib**

```apex
Account account = (Account) SOQLEvaluator.of([
    SELECT Id, Name
    FROM Account
    WHERE Id = '1234'
    WITH USER_MODE
    LIMIT 1
]).toObject();
```

## toList

**Apex**

```apex
List<Account> accounts = [SELECT Id, Name FROM Account WITH USER_MODE];
```

**SOQL Lib**

```apex
List<Account> accounts = SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toList();
```

## toMap

**Apex**

```apex
Map<Id, Account> idToAccount = new Map<Id, Account>([SELECT Id FROM Account WITH USER_MODE]);
```

**SOQL Lib**

```apex
Map<Id, Account> idToAccount = (Map<Id, Account>) SOQLEvaluator.of([
    SELECT Id 
    FROM Account
    WITH USER_MODE
]).toMap();
```

## toMap with custom key

**Apex**

```apex
Map<String, Account> nameToAccount = new Map<String, Account>();

for (Account acc : [SELECT Id, Name FROM Account WITH USER_MODE]) {
    nameToAccount.put(acc.Name, acc);
}
```

**SOQL Lib**

```apex
Map<String, Account> nameToAccount = (Map<String, Account>) SOQLEvaluator.of([
    SELECT Id, Name 
    FROM Account
    WITH USER_MODE
]).toMap(Account.Name);
```

## toMap with custom relationship key

**Apex**

```apex
Map<String, Account> createdByEmailToAccount = new Map<String, Account>();

for (Account acc : [SELECT Id, CreatedBy.Email FROM Account WITH USER_MODE]) {
    if (acc.CreatedBy?.Email != null) {
        createdByEmailToAccount.put(acc.CreatedBy.Email, acc);
    }
}
```

**SOQL Lib**

```apex
Map<String, Account> createdByEmailToAccount = (Map<String, Account>) SOQLEvaluator.of([
    SELECT Id, CreatedBy.Email 
    FROM Account
    WITH USER_MODE
]).toMap('CreatedBy', User.Email);
```

## toMap with custom key and value

**Apex**

```apex
Map<String, String> accountNameToIndustry = new Map<String, String>();

for (Account acc : [SELECT Id, Name, Industry FROM Account WITH USER_MODE]) {
    accountNameToIndustry.put(acc.Name, acc.Industry);
}
```

**SOQL Lib**

```apex
Map<String, String> accountNameToIndustry = SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toMap(Account.Name, Account.Industry);
```

## toAggregatedMap

**Apex**

```apex
Map<String, List<Account>> industryToAccounts = new Map<String, List<Account>>();

for (Account acc : [SELECT Id, Name, Industry FROM Account WITH USER_MODE]) {
    if (!industryToAccounts.containsKey(acc.Industry)) {
        industryToAccounts.put(acc.Industry, new List<Account>());
    }
    industryToAccounts.get(acc.Industry).add(acc);
}
```

**SOQL Lib**

```apex
Map<String, List<Account>> industryToAccounts = (Map<String, List<Account>>) SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toAggregatedMap(Account.Industry);
```

## toAggregatedMap with relationship key

**Apex**

```apex
Map<String, List<Account>> createdByEmailToAccounts = new Map<String, List<Account>>();

for (Account acc : [SELECT Id, Name, CreatedBy.Email FROM Account WITH USER_MODE]) {
    String email = acc.CreatedBy?.Email;
    if (email != null) {
        if (!createdByEmailToAccounts.containsKey(email)) {
            createdByEmailToAccounts.put(email, new List<Account>());
        }
        createdByEmailToAccounts.get(email).add(acc);
    }
}
```

**SOQL Lib**

```apex
Map<String, List<Account>> createdByEmailToAccounts = (Map<String, List<Account>>) SOQLEvaluator.of([
    SELECT Id, Name, CreatedBy.Email 
    FROM Account
    WITH USER_MODE
]).toAggregatedMap('CreatedBy', User.Email);
```

## toAggregatedMap with custom key and value

**Apex**

```apex
Map<String, List<String>> industryToAccountNames = new Map<String, List<String>>();

for (Account acc : [SELECT Id, Name, Industry FROM Account WITH USER_MODE]) {
    if (!industryToAccountNames.containsKey(acc.Industry)) {
        industryToAccountNames.put(acc.Industry, new List<String>());
    }
    industryToAccountNames.get(acc.Industry).add(acc.Name);
}
```

**SOQL Lib**

```apex
Map<String, List<String>> industryToAccountNames = SOQLEvaluator.of([
    SELECT Id, Name, Industry 
    FROM Account
    WITH USER_MODE
]).toAggregatedMap(Account.Industry, Account.Name);
```