/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 * 
 * v6.0.0
 * 
 **/
@IsTest
private class SOQLEvaluator_Test {
    @IsTest
    static void sObjectToId() {
        // Setup
        insertAccount();

        // Test
        Id accountId = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toId();

        // Verify
        Assert.isNotNull(accountId, 'The account id should not be null.');
    }

    @IsTest
    static void sObjectToIdWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test Account'));

        // Test
        Id accountId = SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toId();

        // Verify
        Assert.isNotNull(accountId, 'The account id should not be null.');
    }

    @IsTest
    static void sObjectsToIds() {
        // Setup
        insertAccounts();

        // Test
        Set<Id> accountIds = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toIds();

        // Verify
        Assert.areEqual(2, accountIds.size(), 'The size of the returned set should be 2.');
    }

    @IsTest
    static void sObjectsToIdsWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        });

        // Test
        Set<Id> accountIds = SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toIds();

        // Verify
        Assert.areEqual(2, accountIds.size(), 'The size of the returned set should be 2.');
    }

    @IsTest
    static void sObjectsToIdsOf() {
        // Setup
        insertAccountsWithParents();

        // Test
        Set<Id> parentAccountIds = SOQLEvaluator.of([SELECT Id, ParentId FROM Account WHERE ParentId != null]).toIdsOf(Account.ParentId);

        // Verify
        Assert.areEqual(2, parentAccountIds.size(), 'The size of the returned set should be 2, because only two accounts have a parent.');
    }

    @IsTest
    static void sObjectsToIdsOfWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Contact>{
            new Contact(FirstName = 'Test 1', LastName = 'Test 1', AccountId = SOQL.IdGenerator.get('001')),
            new Contact(FirstName = 'Test 2', LastName = 'Test 2', AccountId = SOQL.IdGenerator.get('001'))
        });

        // Test
        Set<Id> accountIds = SOQLEvaluator.of([SELECT Id, FirstName, LastName FROM Contact]).mockId('mockingQuery').toIdsOf(Contact.AccountId);

        // Verify
        Assert.areEqual(2, accountIds.size(), 'The size of the returned set should be 2.');
    }

    @IsTest
    static void sObjectDoExist() {
        // Setup
        insertAccount();

        // Test
        Boolean doesExist = SOQLEvaluator.of([SELECT Id, Name FROM Account]).doExist();

        // Verify
        Assert.isTrue(doesExist, 'The account should exist.');
    }

    @IsTest
    static void sObjectDoExistWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test Account'));
        
        // Test
        Boolean doesExist = SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').doExist();

        // Verify
        Assert.isTrue(doesExist, 'The account should exist.');
    }

    @IsTest
    static void sObjectToValueOf() {
        // Setup
        insertAccount();

        // Test
        String accountName = (String) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toValueOf(Account.Name);

        // Verify
        Assert.areEqual('Test Account', accountName, 'The account name should be "Test Account".');
    }

    @IsTest
    static void sObjectToValueOfWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test Account'));
        
        // Test
        String accountName = (String)SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toValueOf(Account.Name);

        // Verify
        Assert.areEqual('Test Account', accountName, 'The account name should be "Test Account".');
    }

    @IsTest
    static void sObjectsToValuesOf() {
        // Setup
        insertAccounts();
        
        // Test
        Set<String> accountNames = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toValuesOf(Account.Name);

        // Verify
        Assert.areEqual(2, accountNames.size(), 'The size of the returned set should be 2.');
    }

    @IsTest
    static void sObjectsToValuesOfWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        });

        // Test
        Set<String> accountNames = SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toValuesOf(Account.Name);

        // Verify
        Assert.areEqual(2, accountNames.size(), 'The size of the returned set should be 2.');
    }

    @IsTest
    static void sObjectToObject() {
        // Setup
        insertAccount();
        
        // Test
        Account account = (Account)SOQLEvaluator.of([SELECT Id, Name FROM Account]).toObject();

        // Verify
        Assert.areEqual('Test Account', account.get('Name'), 'The account name should be "Test Account".');
    }

    @IsTest
    static void sObjectToObjectWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test Account'));
        
        // Test
        Account account = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toObject();

        // Verify
        Assert.areEqual('Test Account', account.get('Name'), 'The account name should be "Test Account".');
    }

    @IsTest
    static void sObjectToObjectWhenNoRecord() {
        // Test
        Account account = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toObject();

        // Verify
        Assert.isNull(account, 'The account should be null.');
    }

    @IsTest
    static void sObjectsToList() {
        // Setup
        insertAccounts();
        
        // Test
        List<Account> accounts = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toList();

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned list should be 2.');
    }   

    @IsTest
    static void sObjectsToListWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        });

        // Test
        List<Account> accounts = SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toList();

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned list should be 2.');
    }
    
    @IsTest
    static void sObjectsToListWhenNoRecords() {
        // Test
        List<Account> accounts = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toList();
        
        // Verify
        Assert.areEqual(0, accounts.size(), 'The size of the returned list should be 0.');
    }

    @IsTest
    static void sObjectsToMap() {
        // Setup
        insertAccounts();
        
        // Test
        Map<Id, Account> accounts = (Map<Id, Account>) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toMap();

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        });
        
        // Test
        Map<Id, Account> accounts = (Map<Id, Account>) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toMap();

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWhenNoRecords() {
        // Test
        Map<Id, Account> accounts = (Map<Id, Account>) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toMap();

        // Verify
        Assert.areEqual(0, accounts.size(), 'The size of the returned map should be 0.');
    }

    @IsTest
    static void sObjectsToMapWithKeyField() {
        // Setup
        insertAccounts();

        // Test
        Map<String, Account> accounts = (Map<String, Account>) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toMap(Account.Name);

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithKeyFieldWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        });
        
        // Test
        Map<String, Account> accounts = (Map<String, Account>) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toMap(Account.Name);

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithKeyFieldWhenNoRecords() {
        // Test
        Map<String, Account> accounts = (Map<String, Account>) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toMap(Account.Name);

        // Verify
        Assert.areEqual(0, accounts.size(), 'The size of the returned map should be 0.');
    }

    @IsTest
    static void sObjectsToMapWithRelatedKeyField() {
        // Setup
        insertAccountsWithParents();
        
        // Test
        Map<String, Account> accounts = (Map<String, Account>) SOQLEvaluator.of([SELECT Id, Parent.Name FROM Account WHERE ParentId != null]).toMap('Parent', Account.Name);

        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithRelatedKeyFieldWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1', Parent = new Account(Name = 'Parent 1')),
            new Account(Name = 'Test 2', Parent = new Account(Name = 'Parent 2'))
        });
        
        // Test
        Map<String, Account> accounts = (Map<String, Account>) SOQLEvaluator.of([SELECT Id, Parent.Name FROM Account WHERE ParentId != null]).mockId('mockingQuery').toMap('Parent', Account.Name);
            
        // Verify
        Assert.areEqual(2, accounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithRelatedKeyFieldWhenNoRecords() {
        // Test
        Map<String, Account> accounts = (Map<String, Account>) SOQLEvaluator.of([SELECT Id, Parent.Name FROM Account WHERE ParentId != null]).toMap('Parent', Account.Name);

        // Verify
        Assert.areEqual(0, accounts.size(), 'The size of the returned map should be 0.');
    }

    static Account insertAccount() {
        Account account = new Account(Name = 'Test Account');
        insert account;
        return account;
    }

    static List<Account> insertAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };
        insert accounts;
        return accounts;
    }

    static List<Account> insertAccountsWithParents() {
        List<Account> parentAccounts = new List<Account>{
            new Account(Name = 'Test 1 Parent'),
            new Account(Name = 'Test 2 Parent')
        };
        insert parentAccounts;

        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', ParentId = parentAccounts[0].Id),
            new Account(Name = 'Test 2', ParentId = parentAccounts[1].Id)
        };
        insert accounts;

        return accounts;
    }
}