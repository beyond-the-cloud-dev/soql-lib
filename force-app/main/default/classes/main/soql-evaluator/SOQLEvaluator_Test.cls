/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 **/
@IsTest
private class SOQLEvaluator_Test {
    @IsTest
    static void evaluateToId() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new Account(Name = 'Test Account'));

        // Test
        Id accountId = SOQLEvaluator.of([SELECT Id, Name FROM Account]).mockId('mockingQuery').toId();

        // Verify
        Assert.isNotNull(accountId, 'The account id should not be null.');
    }

    @IsTest
    static void evaluateToIds() {
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
    static void evaluateToIdsOf() {
        // Setup
        SOQLEvaluator.mock('mockingQuery').thenReturn(new List<Contact>{
            new Contact(FirstName = 'Test 1', LastName = 'Test 1', AccountId = SOQL.IdGenerator.get('001')),
            new Contact(FirstName = 'Test 2', LastName = 'Test 2', AccountId = SOQL.IdGenerator.get('001'))
        });

        // Test
        Set<Id> accountIds = SOQL.of([SELECT Id, FirstName, LastName FROM Contact]).mockId('mockingQuery').toIdsOf(Contact.AccountId);

        // Verify
        Assert.areEqual(2, accountIds.size(), 'The size of the returned set should be 2.');
    }

    // Helper Methods

}