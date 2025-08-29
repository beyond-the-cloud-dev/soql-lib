/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * v6.0.1
 *
 * PMD False Positives:
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE test class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - ApexDoc: Variable names are self-documented.
**/
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.ApexDoc')
@IsTest
private class SOQLCache_Test {
    private static final String INITIAL_QUERY_MOCK_ID = 'cachedProfile';
    private static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    private static final String STANDARD_USER = 'Standard User';

    @IsTest
    static void initialQuery() {
        // Setup
        List<Profile> mockedProfiles = new List<Profile>{
            new Profile(Name = SYSTEM_ADMINISTRATOR),
            new Profile(Name = STANDARD_USER)
        };

        SOQL.mock(INITIAL_QUERY_MOCK_ID).thenReturn(mockedProfiles);

        // Test
        new SOQL_ProfileCache().whereEqual('Name', SYSTEM_ADMINISTRATOR).toObject(); // initial query will be executed
        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(mockedProfiles.size(), cachedProfiles.size(), 'The cached profiles should be identical to those in the initial query.');
    }

    @IsTest
    static void noInitialQuery() {
        // Test
        new SOQL_ProfileCacheDefault().whereEqual('Name', SYSTEM_ADMINISTRATOR).toObject();
        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.areEqual(1, cachedProfiles.size(), 'Only one record should be cached.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, cachedProfile.Name, 'The System Administrator profile should be cached.');
    }

    @IsTest
    static void additionalAllowedConditionFields() {
        // Setup
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            User user = (User) new SOQL_UserCache().whereEqual(User.Username, 'test@test.com').toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNull(soqlException, 'An exception should not be thrown, because Username is an additional allowed condition field.');
    }

    @IsTest
    static void multipleSelectorInvocation() {
        // Test
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR).toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR).toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR).toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR).toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'Only the first query should be executed to populate data in the cache.');
    }

    @IsTest
    static void multipleSelectorInvocationWithDifferentConditions() {
        // Test
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR).toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, STANDARD_USER).toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR).toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, STANDARD_USER).toObject();

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Only the one query for each condition should be executed.');
    }

    @IsTest
    static void multipleSelectorInvocationWhenPlainFieldsWereAlreadySet() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'Only the one query should be executed, because the first query set all necessary fields.');
    }

    @IsTest
    static void multipleSelectorInvocationWhenPlainFieldsAreMissing() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name, Profile.UserType)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be executed, because the first query haven\'t set all necessary fields.');
    }

    @IsTest
    static void multipleSelectorInvocationWhenRelationshipFieldsWereAlreadySet() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'Only the one query should be executed, because the first query set all necessary fields.');
    }

    @IsTest
    static void multipleSelectorInvocationWhenRelationshipFieldsAreMissing() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be executed, because the first query haven\'t set all necessary fields.');
    }

    @IsTest
    static void ofString() {
        // Test
        Profile profile = (Profile) SOQLCache.of('Profile').
            with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void cacheInApexTransaction() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .cacheInApexTransaction()
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void cacheInOrgCache() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .cacheInOrgCache()
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.SOQLOrgCache.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void cacheInSessionCache() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .cacheInSessionCache()
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.SOQLSessionCache.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void maxHoursWithoutRefreshRecentRecord() {
        // Setup
        SOQLCache.CacheItem cachedItem = new SOQLCache.CacheItem([
            SELECT Id, Name FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR LIMIT 1
        ]);

        CacheManager.ApexTransaction.put('Profile', new List<SOQLCache.CacheItem>{ cachedItem });

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .maxHoursWithoutRefresh(5)
            .toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'One queries should be issued. The second query should retrieve record from cache.');
        Assert.isNotNull(profile, 'Profile should be not null.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void maxHoursWithoutRefreshOldRecord() {
        // Setup
        SOQLCache.CacheItem cachedItem = new SOQLCache.CacheItem([
            SELECT Id, Name FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR LIMIT 1
        ]);
        cachedItem.cachedDate = DateTime.now().addHours(-6);

        CacheManager.ApexTransaction.put('Profile', new List<SOQLCache.CacheItem>{ cachedItem });

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .maxHoursWithoutRefresh(3)
            .toObject();

        List<SOQLCache.CacheItem> updatedCacheItems = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be issued. The second query should update cached record.');
        Assert.areEqual(1, updatedCacheItems.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.isTrue(Math.abs((System.now().getTime() - updatedCacheItems[0].cachedDate.getTime()) / 1000) < 10, 'The cached record should be updated. The time difference should be less than 10 seconds.');
        Assert.isNotNull(profile, 'Profile should be not null.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void maxHoursWithoutRefreshRecordDoesNotExistAnymore() {
        // Setup
        SOQLCache.CacheItem cachedItem1 = new SOQLCache.CacheItem(new Profile(Id = SOQL.IdGenerator.get(Profile.SObjectType), Name = 'ProfileNotExistName'));
        cachedItem1.cachedDate = DateTime.now().addHours(-6);
        SOQLCache.CacheItem cachedItem2 = new SOQLCache.CacheItem(new Profile(Id = SOQL.IdGenerator.get(Profile.SObjectType), Name = SYSTEM_ADMINISTRATOR));

        CacheManager.ApexTransaction.put('Profile', new List<SOQLCache.CacheItem>{ cachedItem1, cachedItem2 });

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'ProfileNotExistName')
            .maxHoursWithoutRefresh(3)
            .toObject();

        List<SOQLCache.CacheItem> updatedCacheItems = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');
        Profile cachedProfile = (Profile) updatedCacheItems[0].record;

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'One queries should be issued.');
        Assert.areEqual(1, updatedCacheItems.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void allowQueryWithoutConditions() {
        // Setup
        insert new Account(Name = 'Test Account');

        // Test
        Account account = (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .allowQueryWithoutConditions()
            .toObject();

        // Verify
        Assert.isNotNull(account, 'The account should be not null');
        Assert.areEqual('Test Account', account.Name, 'The account name should be "Test Account"');
    }

    @IsTest
    static void allowFilteringByNonUniqueFields() {
        // Setup
        insert new Account(Name = 'Test Account');

        // Setup
        Account account = (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .whereEqual(Account.Name, 'Test Account')
            .allowFilteringByNonUniqueFields()
            .toObject();

        // Verify
        Assert.isNotNull(account, 'The account should be not null');
        Assert.areEqual('Test Account', account.Name, 'The account name should be "Test Account"');
    }

    @IsTest
    static void listHasMoreThanOneRowForAssignmentToSObject() {
        // Setup
        System.QueryException queryException = null;

        // Test
        try {
            SOQLCache.of(Profile.SObjectType)
                .allowQueryWithoutConditions()
                .toObject();
        } catch (System.QueryException e) {
            queryException = e;
        }

        // Verify
        Assert.isNotNull(queryException, 'An exception should be thrown');
        Assert.areEqual(queryException.getMessage(), 'List has more than 1 row for assignment to SObject', 'The exception message should be "List has more than 1 row for assignment to SObject"');
    }

    @IsTest
    static void withOneField() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Name)
           .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be null.');
    }

    @IsTest
    static void withTwoFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Id, Profile.Name)
           .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be set.');
    }


    @IsTest
    static void withThreeFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Id, Profile.Name, Profile.UserType)
           .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile.isSet('UserType'), 'The profile Name should not be set.');
    }


    @IsTest
    static void withFourFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Id, Profile.Name, Profile.UserType, Profile.UserLicenseId)
           .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile.isSet('UserType'), 'The profile UserType should not be set.');
        Assert.isTrue(profile.isSet('UserLicenseId'), 'The profile UserLicenseId should not be set.');
    }

    @IsTest
    static void withFiveFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Id, Profile.Name, Profile.UserType, Profile.Description, Profile.UserLicenseId)
           .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile.isSet('UserType'), 'The profile UserType should not be set.');
        Assert.isTrue(profile.isSet('Description'), 'The profile Description should not be set.');
        Assert.isTrue(profile.isSet('UserLicenseId'), 'The profile UserLicenseId should not be set.');
    }

    @IsTest
    static void withListOfSObjectFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(new List<SObjectField>{
                Profile.Id,
                Profile.Name,
                Profile.UserType,
                Profile.Description,
                Profile.UserLicenseId
           })
           .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile.isSet('UserType'), 'The profile UserType should not be set.');
        Assert.isTrue(profile.isSet('Description'), 'The profile Description should not be set.');
        Assert.isTrue(profile.isSet('UserLicenseId'), 'The profile UserLicenseId should not be set.');
    }

    @IsTest
    static void withCommaSeparatedFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('Id, Name, UserType, UserLicense.Name, UserLicense.Status')
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.Id, 'The profile Id should not be null.');
        Assert.isNotNull(profile.Name, 'The profile Name should not be null.');
        Assert.isNotNull(profile.UserType, 'The profile UserType should not be null.');
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
    }

    @IsTest
    static void withOneRelationshipField() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
    }

    @IsTest
    static void withTwoRelationshipFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
    }

    @IsTest
    static void withThreeRelationshipFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status, UserLicense.MasterLabel)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
        Assert.isNotNull(profile.UserLicense.MasterLabel, 'The profile UserLicense.MasterLabel should not be null.');
    }

    @IsTest
    static void withFourRelationshipFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status, UserLicense.MasterLabel, UserLicense.LicenseDefinitionKey)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
        Assert.isNotNull(profile.UserLicense.MasterLabel, 'The profile UserLicense.MasterLabel should not be null.');
        Assert.isNotNull(profile.UserLicense.LicenseDefinitionKey, 'The profile UserLicense.LicenseDefinitionKey should not be null.');
    }

    @IsTest
    static void withFiveRelationshipFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status, UserLicense.MasterLabel, UserLicense.LicenseDefinitionKey, UserLicense.TotalLicenses)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
        Assert.isNotNull(profile.UserLicense.MasterLabel, 'The profile UserLicense.MasterLabel should not be null.');
        Assert.isNotNull(profile.UserLicense.LicenseDefinitionKey, 'The profile UserLicense.LicenseDefinitionKey should not be null.');
        Assert.isNotNull(profile.UserLicense.TotalLicenses, 'The profile UserLicense.TotalLicenses should not be null.');
    }

    @IsTest
    static void withListOfRelationshipFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', new List<SObjectField>{
                UserLicense.Name,
                UserLicense.Status,
                UserLicense.MasterLabel
            })
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
        Assert.isNotNull(profile.UserLicense.MasterLabel, 'The profile UserLicense.MasterLabel should not be null.');
    }

    @IsTest
    static void withPlainAndRelationshipFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .with('UserLicense', UserLicense.Name, UserLicense.Status, UserLicense.MasterLabel)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.isNotNull(profile.Id, 'The profile Id should not be null.');
        Assert.isNotNull(profile.Name, 'The profile Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Name, 'The profile UserLicense.Name should not be null.');
        Assert.isNotNull(profile.UserLicense.Status, 'The profile UserLicense.Status should not be null.');
        Assert.isNotNull(profile.UserLicense.MasterLabel, 'The profile UserLicense.MasterLabel should not be null.');
    }

    @IsTest
    static void withInvalidRelationshipField() {
        // Setup
        System.QueryException queryException;

        // Test
        try {
            // First query to cache plain fields
            SOQLCache.of(Profile.SObjectType)
                .with(Profile.Id, Profile.Name)
                .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
                .toObject();

            SOQLCache.of(Profile.SObjectType)
                .with(Profile.Id, Profile.Name)
                .with('UserLicense.InvalidPath', UserLicense.Name)
                .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
                .toObject();
        } catch (System.QueryException e) {
            queryException = e;
        }

        // Verify
        Assert.isNotNull(queryException, 'An exception should be thrown when the relationship field is invalid.');
    }

    @IsTest
    static void whereEqualSObjectField() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void whereEqualStringField() {
        // Test
        // First query to cache the record
        Profile profile1 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual('Name', SYSTEM_ADMINISTRATOR)
            .toObject();

        // Second query to retrieve the cached record
        Profile profile2 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual('Name', SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile1.Name, 'The cached profile record should be "System Administrator".');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile2.Name, 'The cached profile record should be "System Administrator".');
        Assert.areEqual(1, Limits.getQueries(), 'The number of queries should be 1.');
    }

    @IsTest
    static void whereEqualIntegerField() {
        insertAccount();

        // Test
        // First query to cache the record
        Account account1 = (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .allowFilteringByNonUniqueFields()
            .whereEqual(Account.NumberOfEmployees, 1000)
            .toObject();

        // Second query to retrieve the cached record
        Account account2 = (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .allowFilteringByNonUniqueFields()
            .whereEqual(Account.NumberOfEmployees, 1000)
            .toObject();

        // Verify
        Assert.areEqual(1000, account1.NumberOfEmployees, 'The cached account record should be 1000.');
        Assert.areEqual(1000, account2.NumberOfEmployees, 'The cached account record should be 1000.');
        Assert.areEqual(1, Limits.getQueries(), 'The number of queries should be 1.');
    }

    @IsTest
    static void whereEqualBooleanField() {
        insertAccount();

        // Test
        // First query to cache the record
        Account account1 = (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.IsDeleted)
            .allowFilteringByNonUniqueFields()
            .whereEqual(Account.IsDeleted, FALSE)
            .toObject();

        // Second query to retrieve the cached record
        Account account2 = (Account) SOQLCache.of(Account.SObjectType)
            .with(Account.Id, Account.IsDeleted)
            .allowFilteringByNonUniqueFields()
            .whereEqual(Account.IsDeleted, FALSE)
            .toObject();

        // Verify
        Assert.areEqual(FALSE, account1.IsDeleted, 'The cached account record should be FALSE.');
        Assert.areEqual(FALSE, account2.IsDeleted, 'The cached account record should be FALSE.');
        Assert.areEqual(1, Limits.getQueries(), 'The number of queries should be 1.');
    }

    @IsTest
    static void whereEqualNotUniqueField() {
        // Setup
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            SOQLCache.of(Profile.SObjectType)
                .with(Profile.Id, Profile.Name)
                .whereEqual(Profile.UserType, 'Standard')
                .toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'An exception should be thrown when the field is not Id, Name, DeveloperName, or a unique field.');
        Assert.areEqual('A cached query can be filtered only by Id, Name, DeveloperName, or a unique field. You can ignore this validation by calling allowFilteringByNonUniqueFields()', soqlException.getMessage(), 'The exception message should be "A cached query can be filtered only by Id, Name, DeveloperName, or a unique field."');
    }

    @IsTest
    static void cachedQueryWithoutCondition() {
        // Setup
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            SOQLCache.of(Profile.SObjectType)
                .with(Profile.Id, Profile.Name)
                .toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'An exception should be thrown when a condition is missing.');
        Assert.areEqual('A condition is missing. Please provide a filter to retrieve the cached record. You can ignore this validation by calling allowQueryWithoutConditions()', soqlException.getMessage(), 'The exception message should be "A condition is missing. Please provide a filter to retrieve the cached record."');
    }

    @IsTest
    static void multipleConditions() {
        // Setup
        SOQLCache.SoqlCacheException soqlException = null;

        // Test
        try {
            Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
                .with(Profile.Id, Profile.Name)
                .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
                .whereEqual(Profile.Id, SOQL.IdGenerator.get(Profile.SObjectType))
                .toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNull(soqlException, 'An exception should not be thrown when more than one condition is introduced.');
    }

    @IsTest
    static void stripInaccessible() {
        // Setup
        Task testTask = new Task(Subject = 'Test Task', Type = 'Other');
        insert testTask;

        System.runAs(minimumAccessUser()) {
            // Test
            Task cachedTask = (Task) SOQLCache.of(Task.SObjectType)
                .with(Task.Id, Task.Type, Task.Subject)
                .whereEqual(Task.Id, testTask.Id)
                .stripInaccessible()
                .toObject();

            Exception queryException = null;

            try {
                String inaccessibleFieldValue = cachedTask.Type;
            } catch(Exception e) {
                queryException = e;
            }

            // Verify
            Assert.areEqual(
                'SObject row was retrieved via SOQL without querying the requested field: Task.Type',
                queryException.getMessage(),
                'The stripInaccessible method should hide the inaccessible field value.'
            );
        }
    }

    @IsTest
    static void mockId() {
        // Setup
        Id profileId = SOQL.IdGenerator.get(Profile.SObjectType);
        SOQLCache.mock('ProfileQuery').thenReturn(new Profile(Id = profileId, Name = SYSTEM_ADMINISTRATOR));

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query()
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(profileId, profile.Id, 'The profile id should be the same as the id assigned to the profile cache.');
        Assert.areEqual(SYSTEM_ADMINISTRATOR, profile.Name, 'The profile name should be the same as the name assigned to the profile cache.');
    }

    @IsTest
    static void mockStack() {
        // Setup
        SOQLCache.mock('mockingQuery').thenReturn(new Profile(Name = 'Test 1'));
        SOQLCache.mock('mockingQuery').thenReturn(new Profile(Name = 'Test 2'));
        SOQLCache.mock('mockingQuery').thenReturn(new Profile(Name = 'Test 3'));

        // Test
        SOQLCache.Cacheable query = SOQLCache.of(Profile.SObjectType)
            .mockId('mockingQuery')
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR);

        Profile profile1 = (Profile) query.toObject();
        Profile profile2 = (Profile) query.toObject();
        Profile profile3 = (Profile) query.toObject();
        Profile profile4 = (Profile) query.toObject();

        // Verify
        Assert.areEqual('Test 1', profile1.Name, 'The profile name should be the same as the name assigned to the profile cache.');
        Assert.areEqual('Test 2', profile2.Name, 'The profile name should be the same as the name assigned to the profile cache.');
        Assert.areEqual('Test 3', profile3.Name, 'The profile name should be the same as the name assigned to the profile cache.');
        Assert.areEqual('Test 3', profile4.Name, 'The profile name should be the same as the name assigned to the profile cache.');
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void preview() {
        // Test
        new SOQL_ProfileCache().query()
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .preview()
            .toObject();

        // Verify - imposible to verify system.debug
    }

    @IsTest
    static void byIdSObject() {
        // Setup
        Profile systemAdministratorProfile = [SELECT Id, Name FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR];

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .byId(systemAdministratorProfile)
            .toObject();

        // Verify
        Assert.areEqual(systemAdministratorProfile.Id, profile.Id, 'The cached profile id should be equal to the systemAdministratorProfile id.');
        Assert.areEqual(systemAdministratorProfile.Name, profile.Name, 'The cached profile name should be equal to the systemAdministratorProfile name.');
    }

    @IsTest
    static void byId() {
        // Setup
        Profile systemAdministratorProfile = [SELECT Id, Name FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR];

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .byId(systemAdministratorProfile.Id)
            .toObject();

        // Verify
        Assert.areEqual(systemAdministratorProfile.Id, profile.Id, 'The cached profile id should be equal to the systemAdministratorProfile id.');
        Assert.areEqual(systemAdministratorProfile.Name, profile.Name, 'The cached profile name should be equal to the systemAdministratorProfile name.');
    }

    @IsTest
    static void toId() {
        // Test
        Id systemAdministratorProfileId = SOQLCache.of(Profile.SObjectType)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toId();

        // Verify
        Assert.isNotNull(systemAdministratorProfileId, 'The System Administrator profile Id must exist.');
    }

    @IsTest
    static void toIdOf() {
        // Test
        Id systemAdministratorProfileId = SOQLCache.of(Profile.SObjectType)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toIdOf(Profile.Id);

        // Verify
        Assert.isNotNull(systemAdministratorProfileId, 'The System Administrator profile Id must exist.');
    }

    @IsTest
    static void doExist() {
        // Test
        Boolean isProfileExist = SOQLCache.of(Profile.SObjectType)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .doExist();

        // Verify
        Assert.isTrue(isProfileExist, 'The System Administrator profile must exist.');
    }

    @IsTest
    static void doNotExist() {
        // Test
        Boolean isProfileExist = SOQLCache.of(Profile.SObjectType)
            .whereEqual(Profile.Name, 'System Administrator NotExist')
            .doExist();

        // Verify
        Assert.isFalse(isProfileExist, 'The System Administrator NotExist profile must not exist.');
    }

    @IsTest
    static void toValueOf() {
        // Test
        Id profileId = (Id) SOQLCache.of(Profile.SObjectType)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toValueOf(Profile.Id);

        // Verify
        Assert.isNotNull(profileId, 'The System Administrator profile Id must exist.');
    }

    @IsTest
    static void toObjectWithMultipleRows() {
        // Setup
        SOQL.mock('ProfileQuery').thenReturn(new List<Profile>{
            new Profile(Id = SOQL.IdGenerator.get(Profile.SObjectType), Name = SYSTEM_ADMINISTRATOR),
            new Profile(Id = SOQL.IdGenerator.get(Profile.SObjectType), Name = SYSTEM_ADMINISTRATOR)
        });

        QueryException queryException = null;

        // Test
        try {
            SOQLCache.of(Profile.SObjectType)
                .mockId('ProfileQuery')
                .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
                .toObject();
        } catch (QueryException e) {
            queryException = e;
        }

        // Verify
        Assert.isNotNull(queryException, 'QueryException should be thrown, because query has more than 1 row for assignment to SObject.');
        Assert.areEqual('List has more than 1 row for assignment to SObject', queryException.getMessage(), 'QueryException message should be "List has more than 1 row for assignment to SObject"');
    }

    @IsTest
    static void recordNotFoundInCache() {
        // Setup
        Id profileId = SOQL.IdGenerator.get(Profile.SObjectType);
        SOQLCache.mock('ProfileQuery').thenReturn(new Profile(Id = profileId, Name = 'Guest User'));

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Guest User')
            .toObject();

        // Verify
        Assert.areEqual(profileId, profile.Id, 'Record not found in cache should be retrieved from SOQL and cached.');
        Assert.areEqual('Guest User', profile.Name, 'Record not found in cache should be retrieved from SOQL and cached.');
    }

    @IsTest
    static void recordNotFoundInCacheAndNotExistInDatabase() {
        // Setup
        SOQL.mock('ProfileQuery').thenReturn(new List<Profile>());

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Profile That Not Exist')
            .toObject();

        // Verify
        Assert.isNull(profile, 'The profile should be null.');
    }

    @IsTest
    static void mockEmptyRecord() {
        // Setup
        SOQLCache.mock('ProfileQuery').thenReturn(null);

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Profile That Not Exist')
            .toObject();

        // Verify
        Assert.isNull(profile, 'The profile should be null.');
        Assert.areEqual(0, Limits.getQueries(), 'No query should be issued.');
    }

    @IsTest
    static void cachedRecordDoesNotHaveNecessaryFields() {
        // Test
        Profile profile1 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        Profile profile2 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name, Profile.UserType, Profile.UserLicenseId) // more fields
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be issued. The second query should retrieve the missing fields.');

        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');

        Assert.isTrue(profile1.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile1.isSet('Name'), 'The profile Name should not be set.');

        Assert.isTrue(profile2.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile2.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile2.isSet('UserType'), 'The profile UserType should not be set.');
        Assert.isTrue(profile2.isSet('UserLicenseId'), 'The profile UserLicenseId should not be set.');
    }

    @IsTest
    static void cachedRecordMissingRelationshipField() {
        // Test
        Profile profile1 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        Profile profile2 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('UserLicense', UserLicense.Name, UserLicense.Status)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be issued. The second query should retrieve the missing fields.');

        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');

        Assert.isNotNull(profile1.UserLicense.Name, 'The profile1 UserLicense.Name should not be null.');

        Assert.isNotNull(profile2.UserLicense.Name, 'The profile2 UserLicense.Name should not be null.');
        Assert.isNotNull(profile2.UserLicense.Status, 'The profile2 UserLicense.Status should not be null.');
    }

    @IsTest
    static void cachedRecordDoesNotHaveRelationshipField() {
        // Test
        Profile profile1 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        Profile profile2 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .with('UserLicense', UserLicense.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be issued. The second query should retrieve the missing relationship fields.');

        Assert.isNotNull(profile1.Id, 'The profile1 Id should not be null.');
        Assert.isNotNull(profile1.Name, 'The profile1 Name should not be null.');

        Assert.isNotNull(profile2.Id, 'The profile2 Id should not be null.');
        Assert.isNotNull(profile2.Name, 'The profile2 Name should not be null.');
        Assert.isNotNull(profile2.UserLicense.Name, 'The profile2 UserLicense.Name should not be null.');
    }

    @IsTest
    static void withCommaSeparatedFieldsWereAlreadySet() {
        // Test
        Profile profile1 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('Id, Name, UserType, UserLicense.Name, UserLicense.Status')
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        Profile profile2 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with('Id, Name, UserType, UserLicense.Name, UserLicense.Status')
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'Only one query should be issued. The second query should not be executed, because the first query set all necessary fields.');
    }

    @IsTest
    static void recordsClearedFromCache() {
        // Setup
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .cacheInOrgCache()
            .toObject();

        // Verify initial setup
        Assert.isTrue(CacheManager.SOQLOrgCache.contains('Profile'), 'Key should exist.');
        Assert.isFalse(((List<SOQLCache.CacheItem>) CacheManager.SOQLOrgCache.get('Profile')).isEmpty(), 'Cache item should be present.');

        // Test
        SOQLCache.removeFromCache(new List<Profile>{ profile });

        // Verify
        Assert.isTrue(CacheManager.SOQLOrgCache.contains('Profile'), 'Key should still exist.');
        Assert.isTrue(((List<SOQLCache.CacheItem>) CacheManager.SOQLOrgCache.get('Profile')).isEmpty(), 'Cache items should be empty.');
    }

    @IsTest
    static void emptyRecordsClearedFromCache() {
        // Setup
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, SYSTEM_ADMINISTRATOR)
            .cacheInOrgCache()
            .toObject();

        // Verify initial setup
        Assert.isTrue(CacheManager.SOQLOrgCache.contains('Profile'), 'Key should exist.');
        Assert.isFalse(((List<SOQLCache.CacheItem>) CacheManager.SOQLOrgCache.get('Profile')).isEmpty(), 'Cache item should be present.');

        // Test
        SOQLCache.removeFromCache(new List<Profile>());

        // Verify
        Assert.isTrue(CacheManager.SOQLOrgCache.contains('Profile'), 'Key should still exist.');
        Assert.isFalse(((List<SOQLCache.CacheItem>) CacheManager.SOQLOrgCache.get('Profile')).isEmpty(), 'Cache items should be not empty.');
    }

    @IsTest
    static void setMock() {
        // Setup
        SOQLCache.setMock('ProfileQuery', new Profile(Name = 'Random Profile Name'));

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Random Profile Name')
            .toObject();

        // Verify
        Assert.areEqual('Random Profile Name', profile.Name, 'The profile name should be the same as the name assigned to the profile cache.');
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

    static Account insertAccount() {
        Account account = new Account(Name = 'Test 1', NumberOfEmployees = 1000);
        insert account;
        return account;
    }

    public class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
        public SOQL_ProfileCache query() {
            return new SOQL_ProfileCache();
        }

        private SOQL_ProfileCache() {
            super(Profile.SObjectType);
            with(Profile.Id, Profile.Name);
        }

        public override SOQL.Queryable initialQuery() {
            return SOQL.of(Profile.SObjectType).mockId(INITIAL_QUERY_MOCK_ID).systemMode().withoutSharing();
        }
    }

    public class SOQL_ProfileCacheDefault extends SOQLCache implements SOQLCache.Selector {
        public SOQL_ProfileCacheDefault query() {
            return new SOQL_ProfileCacheDefault();
        }

        private SOQL_ProfileCacheDefault() {
            super(Profile.SObjectType);
            with(Profile.Id, Profile.Name, Profile.UserType);
        }
    }

    public class SOQL_UserCache extends SOQLCache implements SOQLCache.Selector {
        public SOQL_UserCache query() {
            return new SOQL_UserCache();
        }

        private SOQL_UserCache() {
            super(User.SObjectType);
            with(User.Id, User.Name);
        }

        public override List<SObjectField> additionalAllowedConditionFields() {
            return new List<SObjectField>{ User.Username };
        }
    }
}
