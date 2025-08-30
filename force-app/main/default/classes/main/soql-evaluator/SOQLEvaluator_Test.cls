/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * v6.0.2
 *
 **/
@IsTest
private class SOQLEvaluator_Test {
    @IsTest
    static void sObjectStripInaccessible() {
        // Setup
        insert new Task(Subject = 'Test', Type = 'Other');

        System.runAs(minimumAccessUser()) {
            // Test
            Task task = (Task) SOQLEvaluator.of(new WithoutSharing().getTasks()).stripInaccessible().toObject();

            Exception queryException = null;

            String inaccessibleFieldValue;

            try {
                inaccessibleFieldValue = task.Type;
            } catch(Exception e) {
                queryException = e;
            }

            // Verify
            Assert.isNotNull(queryException, 'The query exception should not be null.');
            Assert.areEqual(
                'SObject row was retrieved via SOQL without querying the requested field: Task.Type',
                queryException.getMessage(),
                'The user should not have access to the \'Type\' field.'
            );
        }
    }

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
            new Contact(FirstName = 'Test 1', LastName = 'Test 1', AccountId = SOQL.IdGenerator.get(Account.SObjectType)),
            new Contact(FirstName = 'Test 2', LastName = 'Test 2', AccountId = SOQL.IdGenerator.get(Account.SObjectType))
        });

        // Test
        Set<Id> accountIds = SOQLEvaluator.of([SELECT Id, FirstName, LastName FROM Contact]).mockId('mockingQuery').toIdsOf(Contact.AccountId);

        // Verify
        Assert.areEqual(2, accountIds.size(), 'The size of the returned set should be 2.');
    }

    @IsTest
    static void sObjectsToIdsOfRelationshipField() {
        // Setup
        insertAccountsWithParents();

        // Test
        Set<Id> createdByIds = SOQLEvaluator.of([SELECT Id, Parent.CreatedById FROM Account WHERE ParentId != null]).toIdsOf('Parent', Account.CreatedById);

        // Verify
        Assert.areEqual(1, createdByIds.size(), 'The size of the returned set should be 1, because the same user inserted the accounts.');
    }

    @IsTest
    static void sObjectsToIdsOfRelationshipFieldWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1', Parent = new Account(ParentId = SOQL.IdGenerator.get(Account.SObjectType))),
            new Account(Name = 'Test 2', Parent = new Account(ParentId = SOQL.IdGenerator.get(Account.SObjectType)))
        });

        // Test
        Set<Id> parentIds = SOQLEvaluator.of([SELECT Id, Parent.ParentId FROM Account WHERE ParentId != null]).mockId('mockingQuery').toIdsOf('Parent', Account.ParentId);

        // Verify
        Assert.areEqual(2, parentIds.size(), 'The size of the returned set should be 2, because the accounts have a parent.');
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
        Account account = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toObject();

        // Verify
        Assert.areEqual('Test Account', account.get('Name'), 'The account name should be "Test Account".');
    }

    @IsTest
    static void sObjectToObjectWithMultipleRows() {
        // Setup
        insertAccounts();
        Exception queryException = null;

        // Test
        try {
            Account account = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).toObject();
        } catch (Exception e) {
            queryException = e;
        }

        // Verify
        Assert.isNotNull(queryException, 'The exception should be thrown, because there are more than 1 row for assignment to SObject.');
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

    @IsTest
    static void sObjectsToMapWithKeyAndValueFields() {
        // Setup
        insertAccounts();

        // Test
        Map<String, String> nameToDescription = SOQLEvaluator.of([SELECT Id, Name, Description FROM Account]).toMap(Account.Name, Account.Description);

        // Verify
        Assert.areEqual(2, nameToDescription.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithKeyAndValueFieldsWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1', Description = 'Description 1'),
            new Account(Name = 'Test 2', Description = 'Description 2')
        });

        // Test
        Map<String, String> nameToDescription = SOQLEvaluator.of([SELECT Id, Name, Description FROM Account]).mockId('mockingQuery').toMap(Account.Name, Account.Description);

        // Verify
        Assert.areEqual(2, nameToDescription.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToMapWithKeyAndValueFieldsWhenNoRecords() {
        // Test
        Map<String, String> nameToDescription = SOQLEvaluator.of([SELECT Id, Name, Description FROM Account]).toMap(Account.Name, Account.Description);

        // Verify
        Assert.areEqual(0, nameToDescription.size(), 'The size of the returned map should be 0.');
    }

    @IsTest
    static void sObjectsToAggregatedMap() {
        // Setup
        insertAccounts();

        // Test
        Map<String, List<Account>> nameToAccounts = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toAggregatedMap(Account.Name);

        // Verify
        Assert.areEqual(2, nameToAccounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1', Industry = 'IT'),
            new Account(Name = 'Test 2', Industry = 'IT')
        });

        // Test
        Map<String, List<Account>> industryToAccounts = SOQLEvaluator.of([SELECT Id, Name, Industry FROM Account]).mockId('mockingQuery').toAggregatedMap(Account.Industry);

        // Verify
        Assert.areEqual(1, industryToAccounts.size(), 'The size of the returned map should be 1, because there is only one industry.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWhenNoRecords() {
        // Test
        Map<String, List<Account>> nameToAccounts = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toAggregatedMap(Account.Name);

        // Verify
        Assert.areEqual(0, nameToAccounts.size(), 'The size of the returned map should be 0.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithRelatedKeyField() {
        // Setup
        insertAccountsWithParents();

        // Test
        Map<String, List<Account>> parentNameToAccounts = SOQLEvaluator.of([SELECT Id, Parent.Name FROM Account WHERE ParentId != null]).toAggregatedMap('Parent', Account.Name);

        // Verify
        Assert.areEqual(2, parentNameToAccounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithRelatedKeyFieldWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1', Parent = new Account(Name = 'Parent 1')),
            new Account(Name = 'Test 2', Parent = new Account(Name = 'Parent 2'))
        });

        // Test
        Map<String, List<Account>> parentNameToAccounts = SOQLEvaluator.of([SELECT Id, Parent.Name FROM Account WHERE ParentId != null]).mockId('mockingQuery').toAggregatedMap('Parent', Account.Name);

        // Verify
        Assert.areEqual(2, parentNameToAccounts.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithRelatedKeyFieldWhenNoRecords() {
        // Test
        Map<String, List<Account>> parentNameToAccounts = SOQLEvaluator.of([SELECT Id, Parent.Name FROM Account WHERE ParentId != null]).toAggregatedMap('Parent', Account.Name);

        // Verify
        Assert.areEqual(0, parentNameToAccounts.size(), 'The size of the returned map should be 0.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithKeyAndValueFields() {
        // Setup
        insertAccounts();

        // Test
        Map<String, List<String>> nameToDescriptions = SOQLEvaluator.of([SELECT Id, Name, Description FROM Account]).toAggregatedMap(Account.Name, Account.Description);

        // Verify
        Assert.areEqual(2, nameToDescriptions.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithKeyAndValueFieldsWithMocking() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Account>{
            new Account(Name = 'Test 1', Description = 'Description 1'),
            new Account(Name = 'Test 2', Description = 'Description 2')
        });

        // Test
        Map<String, List<String>> nameToDescriptions = SOQLEvaluator.of([SELECT Id, Name, Description FROM Account]).mockId('mockingQuery').toAggregatedMap(Account.Name, Account.Description);

        // Verify
        Assert.areEqual(2, nameToDescriptions.size(), 'The size of the returned map should be 2.');
    }

    @IsTest
    static void sObjectsToAggregatedMapWithKeyAndValueFieldsWhenNoRecords() {
        // Test
        Map<String, List<String>> nameToDescriptions = SOQLEvaluator.of([SELECT Id, Name, Description FROM Account]).toAggregatedMap(Account.Name, Account.Description);

        // Verify
        Assert.areEqual(0, nameToDescriptions.size(), 'The size of the returned map should be 0.');
    }

    @IsTest
    static void sObjectsMockStack() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test 1'));
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test 2'));
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test 3'));

        // Test
        Account account1 = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toObject();
        Account account2 = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toObject();
        Account account3 = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toObject();
        Account account4 = (Account) SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toObject();

        // Verify
        Assert.areEqual('Test 1', account1.get('Name'), 'The account name should be "Test 1".');
        Assert.areEqual('Test 2', account2.get('Name'), 'The account name should be "Test 2".');
        Assert.areEqual('Test 3', account3.get('Name'), 'The account name should be "Test 3".');
        Assert.areEqual('Test 3', account4.get('Name'), 'The account name should be "Test 3".');
    }

    static Account insertAccount() {
        Account account = new Account(Name = 'Test Account');
        insert account;
        return account;
    }

    static List<Account> insertAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', Description = 'Description 1'),
            new Account(Name = 'Test 2', Description = 'Description 2')
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

    static User minimumAccessUser() {
        return new User(
            Alias = 'newUser',
            Email = 'newuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Profile = new Profile(Name = 'Minimum Access - Salesforce'),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'queryselector@testorg.com'
        );
    }

    public without sharing class WithoutSharing {
        public List<Task> getTasks() {
            return [SELECT Id, Subject, Type FROM Task WITH SYSTEM_MODE];
        }
    }
}
