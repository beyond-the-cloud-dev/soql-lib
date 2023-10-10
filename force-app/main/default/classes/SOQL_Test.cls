/**
 * Copyright (c) 2023 BeyondTheCloud.Dev
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE test class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - ApexDoc: Variable names are self-documented.
**/
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.ApexDoc')
@IsTest
private class SOQL_Test {

    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static final Id FAKE_ACCOUNT_ID = '0013V00000WNCwCQAX';

    @IsTest
    static void ofSObjectType() {
        // Test
        String soql = SOQL.of(Account.SObjectType).toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account', soql);
    }

    @IsTest
    static void ofString() {
        // Test
        String soql = SOQL.of('Account').toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account', soql);
    }

    @IsTest
    static void count() {
        // Test
        String soql = SOQL.of(Account.SObjectType).count().toString();

        // Verify
        Assert.areEqual('SELECT COUNT() FROM Account', soql);
    }

    @IsTest
    static void countField() {
        // Test
        String soql = SOQL.of(Opportunity.SObjectType)
            .count(Opportunity.Id)
            .count(Opportunity.CampaignId)
            .toString();

        // Verify
        Assert.areEqual('SELECT COUNT(Id), COUNT(CampaignId) FROM Opportunity', soql);
    }

    @IsTest
    static void countWithAlias() {
         // Test
        String soql = SOQL.of(Account.SObjectType).count(Account.Name, 'names').toString();

         // Verify
        Assert.areEqual('SELECT COUNT(Name) names FROM Account', soql);
    }

    @IsTest
    static void grouping() {
         // Test
        String soql = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource, Lead.Rating)
            .grouping(Lead.LeadSource, 'grpLS')
            .grouping(Lead.Rating, 'grpRating')
            .count(Lead.Name, 'cnt')
            .groupByRollup(Lead.LeadSource)
            .groupByRollup(Lead.Rating)
            .toString();

         // Verify
        Assert.areEqual('SELECT LeadSource, Rating, GROUPING(LeadSource) grpLS, GROUPING(Rating) grpRating, COUNT(Name) cnt FROM Lead GROUP BY ROLLUP(LeadSource, Rating)', soql);
    }

    @IsTest
    static void withField() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(Account.BillingCity)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withTwoFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withThreeFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withFourFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountNumber)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, BillingCity, AccountNumber FROM Account', soql);
    }

    @IsTest
    static void withFiveFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountNumber, Account.AccountSource)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, BillingCity, AccountNumber, AccountSource FROM Account', soql);
    }

    @IsTest
    static void withListOfFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Id,
                Account.Name,
                Account.Industry,
                Account.AccountNumber,
                Account.AnnualRevenue,
                Account.BillingCity
            }).toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, Industry, AccountNumber, AnnualRevenue, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withListOfStringFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<String>{
                'Id',
                'Name',
                'Industry',
                'AccountNumber',
                'AnnualRevenue',
                'BillingCity'
            }).toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, Industry, AccountNumber, AnnualRevenue, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withStringFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with('Id, Name, BillingCity')
            .toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withFieldAlias() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, 'myAlias')
            .groupBy(Account.Name)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name myAlias FROM Account GROUP BY Name', soql);
    }

    @IsTest
    static void withDuplicatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with('Id, Name, BillingCity')
            .with(Account.Id, Account.Name)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id, Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withRelatedField() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .with('CreatedBy', User.Name)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Name FROM Account', soql);
    }

    @IsTest
    static void withTwoRelatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .with('CreatedBy', User.Id, User.Name)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name FROM Account', soql);
    }

    @IsTest
    static void withThreeRelatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .with('CreatedBy', User.Id, User.Name, User.Alias)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name, CreatedBy.Alias FROM Account', soql);
    }

    @IsTest
    static void withFourRelatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .with('CreatedBy', User.Id, User.Name, User.Alias, User.City)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name, CreatedBy.Alias, CreatedBy.City FROM Account', soql);
    }

    @IsTest
    static void withFiveRelatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .with('CreatedBy', User.Id, User.Name, User.Alias, User.City, User.CompanyName)
            .toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name, CreatedBy.Alias, CreatedBy.City, CreatedBy.CompanyName FROM Account', soql);
    }

    @IsTest
    static void withRelatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .with('CreatedBy', new List<SObjectField>{
                User.Id, User.Name
            }).toString();

        // Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name FROM Account', soql);
    }

    @IsTest
    static void subQueryField() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryTwoFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryThreeFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name, Contact.AccountId)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name, AccountId FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryFourFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name, Contact.AccountId, Contact.Email)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name, AccountId, Email FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryFiveFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name, Contact.AccountId, Contact.Email, Contact.Phone)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name, AccountId, Email, Phone FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryRelatedFields() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .with('CreatedBy', new List<SObjectField>{
                    User.Id, User.Name
                })
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryTwoLevels() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.LastName)
                .with(SOQL.SubQuery.of('Assets')
                    .with(Asset.AssetLevel)
                )
            )
            .toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT LastName , (SELECT AssetLevel FROM Assets) FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryWhereFilterGroup() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .whereAre(SOQL.FilterGroup
                    .add(SOQL.Filter.with(Contact.LastName).equal('Doe'))
                )
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts WHERE (LastName = :v1)) FROM Account', soql);
    }

    @IsTest
    static void subQueryWhereFilter() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .whereAre(SOQL.Filter.with(Contact.LastName).equal('Doe'))
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts WHERE LastName = :v1) FROM Account', soql);
    }

    @IsTest
    static void subQueryOrderBy() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .orderBy(Contact.Name)
                .sortDesc()
                .nullsLast()
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY Name DESC NULLS LAST) FROM Account', soql);
    }

    @IsTest
    static void subQueryOrderByRelated() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .orderBy('CreatedBy', User.Name)
                .sortDesc()
                .nullsLast()
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY CreatedBy.Name DESC NULLS LAST) FROM Account', soql);
    }

    @IsTest
    static void subQuerySetLimit() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .setLimit(10)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts LIMIT 10) FROM Account', soql);
    }

    @IsTest
    static void subQueryOffset() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .offset(100)
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts OFFSET 100) FROM Account', soql);
    }

    @IsTest
    static void subQueryForReference() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .forReference()
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR REFERENCE) FROM Account', soql);
    }

    @IsTest
    static void subQueryForView() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id, Contact.Name)
                .forView()
            ).toString();

        // Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR VIEW) FROM Account', soql);
    }

    @IsTest
    static void delegatedScope() {
        // Test
        String soql = SOQL.of(Task.SObjectType)
            .delegatedScope()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Task USING SCOPE DELEGATED', soql);
    }

    @IsTest
    static void mineScope() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .mineScope()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE MINE', soql);
    }

    @IsTest
    static void mineAndMyGroupsScope() {
        // Test
        String soql = SOQL.of(ProcessInstanceWorkItem.SObjectType)
            .mineAndMyGroupsScope()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM ProcessInstanceWorkitem USING SCOPE MINE_AND_MY_GROUPS', soql);
    }

    @IsTest
    static void myTerritoryScope() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .myTerritoryScope()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TERRITORY', soql);
    }

    @IsTest
    static void myTeamTerritoryScope() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .myTeamTerritoryScope()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TEAM_TERRITORY', soql);
    }

    @IsTest
    static void teamScope() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .teamScope()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE TEAM', soql);
    }

    @IsTest
    static void id() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.id().isNotNull());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void recordType() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.recordType().isNotNull());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE RecordType.DeveloperName != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void name() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.name().isNotNull());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void withRelatedFieldFilter() {
        // Test
        SOQL builder = SOQL.of(Contact.SObjectType)
            .whereAre(SOQL.Filter.with('Account', Account.Name).equal('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Contact WHERE Account.Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @IsTest
    static void equalString() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).equal('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @IsTest
    static void notEqualString() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notEqual('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @IsTest
    static void lessThan() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThan(10));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees < :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void greaterThan() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThan(10));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees > :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void lessOrEqual() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessOrEqual(10));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees <= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void greaterOrEqual() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterOrEqual(10));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void contains() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).contains('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test%', binding.get('v1'));
    }

    @IsTest
    static void notContains() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notContains('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (NOT Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test%', binding.get('v1'));
    }

    @IsTest
    static void containsValues() {
        // Setup
        List<String> names = new List<String>{ 'Acc', 'My' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).containsSome(names));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @IsTest
    static void endsWith() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).endsWith('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test', binding.get('v1'));
    }

    @IsTest
    static void notEndsWith() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notEndsWith('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (NOT Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test', binding.get('v1'));
    }

    @IsTest
    static void startsWith() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).startsWith('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test%', binding.get('v1'));
    }

    @IsTest
    static void notStartsWith() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notStartsWith('Test'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (NOT Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test%', binding.get('v1'));
    }

    @IsTest
    static void customContains() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).contains('_', 'Test', '%'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('_Test%', binding.get('v1'));
    }

    @IsTest
    static void customNotContains() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notContains('_', 'Test', '%'));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (NOT Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('_Test%', binding.get('v1'));
    }

    @IsTest
    static void isInSet() {
        // Setup
        Set<String> names = new Set<String>{ 'Test 1', 'Test 2' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isIn(names));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @IsTest
    static void isInList() {
        // Setup
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isIn(names));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @IsTest
    static void notInSet() {
        // Setup
        Set<String> names = new Set<String>{ 'Test 1', 'Test 2' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notIn(names));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name NOT IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @IsTest
    static void notInList() {
        // Setup
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.BillingCity)
            .whereAre(SOQL.Filter.with(Account.Name).notIn(names));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE Name NOT IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @IsTest
    static void inlcudesAll() {
        // Setup
        List<String> ratings = new List<String>{ 'Hot', 'Warm' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .with(Account.Id)
            .whereAre(SOQL.Filter.with(Account.Rating).includesAll(ratings));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Rating INCLUDES (\'Hot;Warm\')', soql);
    }

    @IsTest
    static void inlcudesSome() {
        // Setup
        List<String> ratings = new List<String>{ 'Hot', 'Warm' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .with(Account.Id)
            .whereAre(SOQL.Filter.with(Account.Rating).includesSome(ratings));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Rating INCLUDES (\'Hot\', \'Warm\')', soql);
    }

    @IsTest
    static void excludesAll() {
        // Setup
        List<String> ratings = new List<String>{ 'Hot', 'Warm' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .with(Account.Id)
            .whereAre(SOQL.Filter.with(Account.Rating).excludesAll(ratings));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Rating EXCLUDES (\'Hot\', \'Warm\')', soql);
    }

    @IsTest
    static void excludesSome() {
        // Setup
        List<String> ratings = new List<String>{ 'Hot', 'Warm' };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .with(Account.Id)
            .whereAre(SOQL.Filter.with(Account.Rating).excludesSome(ratings));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Rating EXCLUDES (\'Hot;Warm\')', soql);
    }

    @IsTest
    static void isNull() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isNull());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void isNotNull() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isNotNull());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void isTrue() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.IsDeleted).isTrue());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE IsDeleted = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.isTrue((Boolean) binding.get('v1'));
    }

    @IsTest
    static void isFalse() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.IsDeleted).isFalse());

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE IsDeleted = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.isFalse((Boolean) binding.get('v1'));
    }

    @IsTest
    static void dateLiteral() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.CreatedDate).greaterThan('LAST_N_QUARTERS:2').asDateLiteral())
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account WHERE CreatedDate > LAST_N_QUARTERS:2', soql);
    }

    @IsTest
    static void filtersGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).equal('Test'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
            );

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @IsTest
    static void emptyFiltersGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FilterGroup);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account', soql);
    }

    @IsTest
    static void dynamicFiltersGroup() {
        // Setup
        SOQL.FilterGroup filterGroup = SOQL.FilterGroup;

        filterGroup.add(SOQL.Filter.with(Account.Name).equal('Test'));
        filterGroup.add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'));

        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(filterGroup);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @IsTest
    static void anyConditionMatchingForInnerGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).equal('Test'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
                .anyConditionMatching()
            );

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 OR BillingCity = :v2)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @IsTest
    static void anyConditionMatchingForMainGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).equal('Test'))
            .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
            .anyConditionMatching();

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1 OR BillingCity = :v2', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @IsTest
    static void conditionLogicForMainGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).equal('Test'))
            .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
            .conditionLogic('1 OR 2');

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1 OR BillingCity = :v2', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @IsTest
    static void nestedFiltersGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).equal('Test'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
                .add(SOQL.FilterGroup
                    .add(SOQL.Filter.with(Account.Name).equal('Test 2'))
                    .add(SOQL.Filter.with(Account.BillingCity).equal('Warsaw'))
                    .conditionLogic('1 OR 2')
                )
            );

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2 AND (Name = :v3 OR BillingCity = :v4))', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
        Assert.areEqual('Test 2', binding.get('v3'));
        Assert.areEqual('Warsaw', binding.get('v4'));
    }

    @IsTest
    static void innerJoinWithFilterGroup() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).isIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.FilterGroup
                        .add(SOQL.Filter.with(Contact.Name).equal('My Contact'))
                    )
            ));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE (Name = :v1))', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }

    @IsTest
    static void inInnerJoin() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).isIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
            ));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }

    @IsTest
    static void isNotInInnerJoin() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).notIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.Filter.name().equal('My Contact'))
            ));

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }

    @IsTest
    static void evaluateStringConditions() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre('NumberOfEmployees >= 10 AND NumberOfEmployees <= 20')
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= 10 AND NumberOfEmployees <= 20', soql);
    }

    @IsTest
    static void evaluateEmptyConditions() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre('')
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account', soql);
    }

    @IsTest
    static void evaluateStringConditionsAndGroup() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre('NumberOfEmployees >= 10 AND NumberOfEmployees <= 20')
            .whereAre(SOQL.Filter.name().equal('My Contact'))
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= 10 AND NumberOfEmployees <= 20 AND Name = :v1', soql);
    }

    @IsTest
    static void evaluateStringAndFilterInFilterGroup() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre(
                SOQL.FilterGroup
                    .add('NumberOfEmployees >= 10 AND NumberOfEmployees <= 20')
                    .add(SOQL.Filter.name().equal('My Contact'))
            )
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account WHERE (NumberOfEmployees >= 10 AND NumberOfEmployees <= 20 AND Name = :v1)', soql);
    }

    @IsTest
    static void ignoreWhen() {
        // Setup
        String accountName = '';

        // Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
                .add(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
            )
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account WHERE (BillingCity = :v1)', soql);
    }

    @IsTest
    static void groupBy() {
        // Test
        String soql = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource)
            .groupBy(Lead.LeadSource)
            .toString();

        // Verify
        Assert.areEqual('SELECT LeadSource FROM Lead GROUP BY LeadSource', soql);
    }

    @IsTest
    static void groupByRollup() {
        // Test
        String soql = SOQL.of(Lead.SObjectType)
            .count(Lead.Name, 'cnt')
            .with(Lead.LeadSource)
            .groupByRollup(Lead.LeadSource)
            .toString();

        // Verify
        Assert.areEqual('SELECT COUNT(Name) cnt, LeadSource FROM Lead GROUP BY ROLLUP(LeadSource)', soql);
    }

    @IsTest
    static void groupByCube() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Type)
            .groupByCube(Account.Type)
            .toString();

        // Verify
        Assert.areEqual('SELECT Type FROM Account GROUP BY CUBE(Type)', soql);
    }

    @IsTest
    static void differentGroupByFunctionsException() {
        // Setup
        Exception queryException = null;

        // Test
        try {
           String soql = SOQL.of(Account.SObjectType)
                .with(Account.Type)
                .groupBy(Account.Type)
                .groupByCube(Account.Type)
                .toString();
        } catch(Exception e) {
            queryException = e;
        }

        // Verify
        Assert.areEqual(
            'You cant use GROUP BY, GROUP BY ROLLUP and GROUP BY CUBE in the same query.',
            queryException.getMessage()
        );
    }

    @IsTest
    static void groupByWithDefaultFields() {
        // Test
        String soql = SOQL.of(Lead.SObjectType)
            .with(Lead.FirstName, Lead.LastName, Lead.Email)
            .with(Lead.LeadSource)
            .groupBy(Lead.LeadSource)
            .toString();

        // Verify
        Assert.areEqual('SELECT LeadSource FROM Lead GROUP BY LeadSource', soql);
    }

    @IsTest
    static void orderByString() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .orderBy('Industry').sortDesc().nullsLast()
            .orderBy('Id')
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry DESC NULLS LAST, Id ASC NULLS FIRST', soql);
    }

    @IsTest
    static void orderByDynamic() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .orderBy('Industry', 'ASC')
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry ASC NULLS FIRST', soql);
    }

    @IsTest
    static void orderBy() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .orderBy(Account.Industry).sortDesc().nullsLast()
            .orderBy(Account.Id)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry DESC NULLS LAST, Id ASC NULLS FIRST', soql);
    }

    @IsTest
    static void orderByRelated() {
        // Test
        String soql = SOQL.of(Contact.SObjectType)
            .orderBy('Account', Account.Name)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Contact ORDER BY Account.Name ASC NULLS FIRST', soql);
    }


    @IsTest
    static void setLimit() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .setLimit(100)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account LIMIT 100', soql);
    }

    @IsTest
    static void offset() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .offset(100)
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account OFFSET 100', soql);
    }

    @IsTest
    static void forReference() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .forReference()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account FOR REFERENCE', soql);
    }

    @IsTest
    static void forView() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .forView()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account FOR VIEW', soql);
    }

    @IsTest
    static void forUpdate() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .forUpdate()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account FOR UPDATE', soql);
    }

    @IsTest
    static void allRows() {
        // Test
        String soql = SOQL.of(Account.SObjectType)
            .allRows()
            .toString();

        // Verify
        Assert.areEqual('SELECT Id FROM Account ALL ROWS', soql);
    }

    @IsTest
    static void byId() {
        // Test
        SOQL builder = SOQL.of(Account.SObjectType).byId(FAKE_ACCOUNT_ID);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(FAKE_ACCOUNT_ID, binding.get('v1'));
    }

    @IsTest
    static void byIdSObject() {
        // Setup
        List<Case> cases = insertCases();

        // Test
        SOQL builder = SOQL.of(Case.SObjectType).byId(cases[0]);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Case WHERE Id = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(cases[0].Id, binding.get('v1'));
    }

    @IsTest
    static void byIdsSet() {
        Set<Id> accountIds = new Set<Id>{ FAKE_ACCOUNT_ID };

        SOQL builder = SOQL.of(Account.SObjectType).byIds(accountIds);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(accountIds, binding.get('v1'));
    }

    @IsTest
    static void byIdsList() {
        // Setup
        List<Id> accountIds = new List<Id>{ FAKE_ACCOUNT_ID };

        // Test
        SOQL builder = SOQL.of(Account.SObjectType).byIds(accountIds);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(accountIds, binding.get('v1'));
    }

    @IsTest
    static void byIdsSObjects() {
        // Setup
        List<Case> cases = insertCases();

        // Test
        SOQL builder = SOQL.of(Case.SObjectType).byIds(cases);

        // Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Case WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(cases, binding.get('v1'));
    }

    @IsTest
    static void toObjectWithoutSharing() {
        // Setup
        Case testCase = new Case(Status = 'New', Origin = 'Web');
        insert testCase;

        System.runAs(standardUser()) {
            // Test
            Case resultCase = (Case) SOQL.of(Case.SObjectType).systemMode().withoutSharing().toObject();

            // Verify
            Assert.areEqual(testCase.Id, resultCase.Id);
        }
    }

    @IsTest
    static void toListWithoutSharing() {
        // Setup
        insertCases();

        System.runAs(standardUser()) {
            // Test
            List<Case> cases = SOQL.of(Case.SObjectType).systemMode().withoutSharing().toList();

            // Verify
            Assert.areEqual(2, cases.size());
        }
    }

    @IsTest
    static void toIntegerWithoutSharing() {
        // Setup
        insertCases();

        System.runAs(standardUser()) {
            // Test
            Integer casesAmount = SOQL.of(Case.SObjectType).count().systemMode().withoutSharing().toInteger();

            // Verify
            Assert.areEqual(2, casesAmount);
        }
    }

    @IsTest
    static void toObjectWithSharing() {
        // Setup
        insert new Task(Subject = 'Test', Type = 'Other');

        System.runAs(standardUser()) {
            // Test
            Task resultTask = (Task) SOQL.of(Task.SObjectType).systemMode().withSharing().toObject();

            // Verify
            Assert.isNull(resultTask);
        }
    }

    @IsTest
    static void toListWithSharing() {
        // Setup
        insertTasks();

        System.runAs(standardUser()) {
            // Test
            List<Task> tasks = SOQL.of(Task.SObjectType).systemMode().withSharing().toList();

            // Verify
            Assert.areEqual(0, tasks.size());
        }
    }

    @IsTest
    static void toIntegerWithSharing() {
        insertTasks();

        System.runAs(standardUser()) {
            // Test
            Integer tasksAmount = SOQL.of(Task.SObjectType).count().systemMode().withSharing().toInteger();

            // Verify
            Assert.areEqual(0, tasksAmount);
        }
    }

    @IsTest
    static void stripInaccessibleToObject() {
        // Setup
        Task testTask = new Task(Subject = 'Test', Type = 'Other');
        insert testTask;

        System.runAs(standardUser()) {
            // Test
            Task task = (Task) SOQL.of(Task.SObjectType)
                .with(Task.Type)
                .systemMode()
                .stripInaccessible()
                .withoutSharing()
                .toObject();

            Exception queryException = null;

            String inaccessibleFieldValue;

            try {
                inaccessibleFieldValue = task.Type;
            } catch(Exception e) {
                queryException = e;
            }

            // Verify
            Assert.areEqual(
                'SObject row was retrieved via SOQL without querying the requested field: Task.Type',
                queryException.getMessage()
            );
        }
    }

    @IsTest
    static void stripInaccessibleToList() {
        // Setup
        insertTasks();

        System.runAs(standardUser()) {
            // Test
            List<Task> tasks = SOQL.of(Task.SObjectType)
                .with(Task.Type)
                .systemMode()
                .stripInaccessible()
                .withoutSharing()
                .toList();

            Exception queryException = null;

            String inaccessibleFieldValue;

            try {
                inaccessibleFieldValue = tasks[0].Type;
            } catch(Exception e) {
                queryException = e;
            }

            // Verify
            Assert.areEqual(
                'SObject row was retrieved via SOQL without querying the requested field: Task.Type',
                queryException.getMessage()
            );
        }
    }

    @IsTest
    static void mockId() {
        // Setup
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };

        // Test
        SOQL.setMock('mockingQuery', accounts);
        List<Account> result = SOQL.of(Account.SObjectType).mockId('mockingQuery').toList();

        // Verify
        Assert.areEqual(accounts, result);
    }

    @IsTest
    static void mockingSingleRecord() {
        // Setup
        Account testAccount = new Account(Name = 'Test 1');

        // Test
        SOQL.setMock('mockingQuery', testAccount);
        Account result = (Account) SOQL.of(Account.sObjectType).mockId('mockingQuery').toObject();

        // Verify
        Assert.areEqual(testAccount, result);
    }

    @IsTest
    static void mockingCount() {
        // Test
        SOQL.setCountMock('mockingQuery', 2);
        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').toInteger();

        // Verify
        Assert.areEqual(2, result);
    }

    @IsTest
    static void doExist() {
        // Setup
        Account acc = new Account(Name = 'Test 1');
        insert acc;

        // Test
        Boolean isRecordExist = SOQL.of(Account.SObjectType).byId(acc).doExist();

        // Verify
        Assert.isTrue(isRecordExist);
    }

    @IsTest
    static void toValueOf() {
        // Setup
        Account acc = new Account(Name = 'Test 1');
        insert acc;

        // Test
        String resultAccName = (String) SOQL.of(Account.SObjectType).byId(acc).toValueOf(Account.Name);

        // Verify
        Assert.areEqual('Test 1', resultAccName);
    }

    @IsTest
    static void toValuesOf() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Set<String> accountNames = SOQL.of(Account.SObjectType).byIds(accounts).toValuesOf(Account.Name);

        // Verify
        Assert.areEqual(2, accountNames.size());
    }

    @IsTest
    static void toValuesOfWithDefaultFields() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Set<String> accountNames = SOQL.of(Account.SObjectType)
            .with(Account.Industry)
            .byIds(accounts)
            .toValuesOf(Account.Name);

        // Verify
        Assert.areEqual(2, accountNames.size());
    }

    @IsTest
    static void toValueOfWhenRecordNotExist() {
        // Test
        String accountIndustry = (String) SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.name().equal('Test'))
            .toValueOf(Account.Industry);

        // Verify
        Assert.isNull(accountIndustry);
    }

    @IsTest
    static void toObject() {
        // Setup
        Account acc = new Account(Name = 'Test 1');
        insert acc;

        // Test
        Account result = (Account) SOQL.of(Account.SObjectType).toObject();

        // Verify
        Assert.areEqual(acc.Id, result.Id);
    }

    @IsTest
    static void toObjectWithMultipleRows() {
        // Setup
        insertAccounts();
        Exception queryException = null;

        // Test
        try {
            Account result = (Account) SOQL.of(Account.SObjectType).toObject();
        } catch (Exception e) {
            queryException = e; // List has more than 1 row for assignment to SObject
        }

        // Verify
        Assert.isNotNull(queryException);
    }

    @IsTest
    static void toObjectWithoutRows() {
        // Test
        // When List has no rows for assignment to SObject null will be returned
        Account account = (Account) SOQL.of(Account.SObjectType).toObject();

        // Verify
        Assert.isNull(account);
    }

    @IsTest
    static void toList() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        List<Account> result = SOQL.of(Account.SObjectType).toList();

        // Verify
        Assert.areEqual(accounts.size(), result.size());
    }

    @IsTest
    static void toAggregated() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        List<AggregateResult> result = SOQL.of(Account.SObjectType).count(Account.Name, 'names').toAggregated();

        // Verify
        Assert.areEqual(accounts.size(), result[0].get('names'));
    }

    @IsTest
    static void toIntegerWithoutCount() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Integer result = SOQL.of(Account.SObjectType).toInteger();

        // Verify
        Assert.areEqual(accounts.size(), result);
    }

    @IsTest
    static void toInteger() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Integer result = SOQL.of(Account.SObjectType).count().toInteger();

        // Verify
        Assert.areEqual(accounts.size(), result);
    }

    @IsTest
    static void toMap() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Map<Id, Account> result = (Map<Id, Account>) SOQL.of(Account.SObjectType).toMap();

        // Verify
        Assert.areEqual(accounts.size(), result.size());

        for (Account acc : accounts) {
            Assert.isNotNull(result.get(acc.Id));
        }
    }

    @IsTest
    static void toMapWithCustomKey() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Map<String, Account> result = (Map<String, Account>) SOQL.of(Account.SObjectType).toMap(Account.Name);

        // Verify
        Assert.areEqual(accounts.size(), result.size());

        for (Account acc : accounts) {
            Assert.isNotNull(result.get(acc.Name));
        }
    }

    @IsTest
    static void toMapWithCustomKeyAndCustomValue() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Map<String, String> result = SOQL.of(Account.SObjectType).toMap(Account.Name, Account.Id);

        // Verify
        Assert.areEqual(accounts.size(), result.size());

        for (Account acc : accounts) {
            Assert.isNotNull(result.get(acc.Name));
        }
    }

    @IsTest
    static void toAggregatedMapWithCustomKey() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Map<String, List<Account>> result = SOQL.of(Account.SObjectType).toAggregatedMap(Account.Name);

        // Verify
        Assert.areEqual(accounts.size(), result.size());

        for (Account acc : accounts) {
            Assert.isFalse(result.get(acc.Name).isEmpty());
        }
    }

    @IsTest
    static void toAggregatedMapWithEmptyCustomKey() {
        // Setup
        insertAccounts();

        // Test
        Map<String, List<Account>> result = SOQL.of(Account.SObjectType).toAggregatedMap(Account.Industry);

        // Verify
        Assert.areEqual(1, result.size()); // grouped by empty Industry
    }

    @IsTest
    static void toAggregatedMapWithCustomKeyAndCustomValue() {
        // Setup
        List<Account> accounts = insertAccounts();

        // Test
        Map<String, List<String>> result = SOQL.of(Account.SObjectType).toAggregatedMap(Account.Name, Account.Id);

        // Verify
        Assert.areEqual(accounts.size(), result.size());

        for (Account acc : accounts) {
            Assert.isFalse(result.get(acc.Name).isEmpty());
        }
    }

    @IsTest
    static void toQueryLocator() {
        // Test
        Database.QueryLocator queryLocator = SOQL.of(Account.SObjectType)
            .with(Account.Id)
            .with(Account.Name)
            .toQueryLocator();


        // Verify
        Assert.areEqual('SELECT Id, Name FROM Account', queryLocator.getQuery());
    }

    static List<Account> insertAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };
        insert accounts;
        return accounts;
    }

    static List<Case> insertCases() {
        List<Case> cases = new List<Case>{
            new Case(Status = 'New', Origin = 'Web'),
            new Case(Status = 'New', Origin = 'Web')
        };
        insert cases;
        return cases;
    }

    static void insertTasks() {
        insert new List<Task>{
            new Task(Subject = 'Test', Type = 'Other'),
            new Task(Subject = 'Test', Type = 'Other')
        };
    }

    static User standardUser() {
        return new User(
            Alias = 'newUser',
            Email = 'newuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'queryselector@testorg.com'
        );
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void preview() {
        // Test
        SOQL.of(Account.SObjectType).preview().toList();
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void previewCount() {
        // Test
        SOQL.of(Account.SObjectType).count().preview().toInteger();
    }
}
