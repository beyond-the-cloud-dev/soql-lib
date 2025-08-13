/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE test class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - ApexDoc: Variable names are self-documented.
 * - AvoidHardcodingId: Hardcoded Ids are used to mock SOQL results
**/
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.ApexDoc, PMD.AvoidHardcodingId')
@IsTest
private class SOQLCache_Test {
    private static final String INITIAL_QUERY_MOCK_ID = 'cachedProfile';

    @IsTest
    static void initialQuery() {
        // Setup
        List<Profile> mockedProfiles = new List<Profile>{
            new Profile(Name = 'System Administrator'),
            new Profile(Name = 'Standard User')
        };
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, mockedProfiles);

        // Test
        new SOQL_ProfileCache().whereEqual('Name', 'System Administrator').toObject(); // initial query will be executed
        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(mockedProfiles.size(), cachedProfiles.size(), 'The cached profiles should be identical to those in the initial query.');
    }

    @IsTest
    static void noInitialQuery() {
        // Test
        new SOQL_ProfileCacheDefault().whereEqual('Name', 'System Administrator').toObject();
        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.areEqual(1, cachedProfiles.size(), 'Only one record should be cached.');
        Assert.areEqual('System Administrator', cachedProfile.Name, 'The System Administrator profile should be cached.');
    }

    @IsTest
    static void multipleSelectorInvocation() {
        // Test
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, 'System Administrator').toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, 'System Administrator').toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, 'System Administrator').toObject();
        SOQLCache.of(Profile.SObjectType).with(Profile.Id, Profile.Name).whereEqual(Profile.Name, 'System Administrator').toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'Only the first query should be executed to populate data in the cache.');
    }

    @IsTest
    static void ofString() {
        // Test
        Profile profile = (Profile) SOQLCache.of('Profile').
            with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('System Administrator', profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void cacheInApexTransaction() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .cacheInApexTransaction()
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual('System Administrator', cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void cacheInOrgCache() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .cacheInOrgCache()
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.SOQLOrgCache.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual('System Administrator', cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void cacheInSessionCache() {
        // Test
        SOQLCache.of(Profile.SObjectType)
            .cacheInSessionCache()
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.SOQLSessionCache.get('Profile');
        Profile cachedProfile = (Profile) cachedProfiles[0].record;

        // Verify
        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.areEqual('System Administrator', cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void maxHoursWithoutRefreshRecentRecord() {
        // Setup
        SOQLCache.CacheItem cachedItem = new SOQLCache.CacheItem([
            SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1
        ]);

        CacheManager.ApexTransaction.put('Profile', new List<SOQLCache.CacheItem>{ cachedItem });

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .maxHoursWithoutRefresh(5)
            .toObject();

        // Verify
        Assert.areEqual(1, Limits.getQueries(), 'One queries should be issued. The second query should retrieve record from cache.');
        Assert.isNotNull(profile, 'Profile should be not null.');
        Assert.areEqual('System Administrator', profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void maxHoursWithoutRefreshOldRecord() {
        // Setup
        SOQLCache.CacheItem cachedItem = new SOQLCache.CacheItem([
            SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1
        ]);
        cachedItem.cachedDate = DateTime.now().addHours(-6);

        CacheManager.ApexTransaction.put('Profile', new List<SOQLCache.CacheItem>{ cachedItem });

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .maxHoursWithoutRefresh(3)
            .toObject();

        List<SOQLCache.CacheItem> updatedCacheItems = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be issued. The second query should update cached record.');
        Assert.areEqual(1, updatedCacheItems.size(), 'The Apex transaction cache should contain exactly one record.');
        Assert.isTrue(Math.abs((System.now().getTime() - updatedCacheItems[0].cachedDate.getTime()) / 1000) < 10, 'The cached record should be updated. The time difference should be less than 10 seconds.');
        Assert.isNotNull(profile, 'Profile should be not null.');
        Assert.areEqual('System Administrator', profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void maxHoursWithoutRefreshRecordDoesNotExistAnymore() {
        // Setup
        SOQLCache.CacheItem cachedItem1 = new SOQLCache.CacheItem(new Profile(Id = '00e3V000000Nme3QAC', Name = 'ProfileNotExistName'));
        cachedItem1.cachedDate = DateTime.now().addHours(-6);
        SOQLCache.CacheItem cachedItem2 = new SOQLCache.CacheItem(new Profile(Id = '00e3V000000Nme3QAD', Name = 'System Administrator'));

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
        Assert.areEqual('System Administrator', cachedProfile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void withOneField() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Name)
           .whereEqual(Profile.Name, 'System Administrator')
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be null.');
    }

    @IsTest
    static void withTwoFields() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
           .with(Profile.Id, Profile.Name)
           .whereEqual(Profile.Name, 'System Administrator')
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
           .whereEqual(Profile.Name, 'System Administrator')
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
           .whereEqual(Profile.Name, 'System Administrator')
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
           .whereEqual(Profile.Name, 'System Administrator')
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
           .whereEqual(Profile.Name, 'System Administrator')
           .toObject();

        // Verify
        Assert.isTrue(profile.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile.isSet('UserType'), 'The profile UserType should not be set.');
        Assert.isTrue(profile.isSet('Description'), 'The profile Description should not be set.');
        Assert.isTrue(profile.isSet('UserLicenseId'), 'The profile UserLicenseId should not be set.');
    }

    @IsTest
    static void whereEqualSObjectField() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('System Administrator', profile.Name, 'The cached profile record should be "System Administrator".');
    }

    @IsTest
    static void whereEqualStringField() {
        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual('Name', 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('System Administrator', profile.Name, 'The cached profile record should be "System Administrator".');
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
        Assert.areEqual('A cached query can be filtered only by Id, Name, DeveloperName, or a unique field.', soqlException.getMessage(), 'The exception message should be "A cached query can be filtered only by Id, Name, DeveloperName, or a unique field."');
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
        Assert.areEqual('A condition is missing. Please provide a filter to retrieve the cached record.', soqlException.getMessage(), 'The exception message should be "A condition is missing. Please provide a filter to retrieve the cached record."');
    }

    @IsTest
    static void multipleConditions() {
        // Setup
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            SOQLCache.of(Profile.SObjectType)
                .with(Profile.Id, Profile.Name)
                .whereEqual(Profile.Name, 'System Administrator')
                .whereEqual(Profile.Id, '00e3V000000NmefQAC')
                .toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'An exception should be thrown when more than one condition is introduced.');
        Assert.areEqual('Only one condition can be used in a cached query.', soqlException.getMessage(), 'The exception message should be "Only one condition can be used in a cached query."');
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
        SOQLCache.setMock('ProfileQuery', new Profile(Id = '00e3V000000Nme3QAC', Name = 'System Administrator'));

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query()
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id, 'The profile id should be the same as the id assigned to the profile cache.');
        Assert.areEqual('System Administrator', profile.Name, 'The profile name should be the same as the name assigned to the profile cache.');
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void preview() {
        // Test
        new SOQL_ProfileCache().query()
            .whereEqual(Profile.Name, 'System Administrator')
            .preview()
            .toObject();

        // Verify - imposible to verify system.debug
    }

    @IsTest
    static void byIdSObject() {
        // Setup
        Profile systemAdministratorProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];

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
        Profile systemAdministratorProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];

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
            .whereEqual(Profile.Name, 'System Administrator')
            .toId();

        // Verify
        Assert.isNotNull(systemAdministratorProfileId, 'The System Administrator profile Id must exist.');
    }

    @IsTest
    static void doExist() {
        // Test
        Boolean isProfileExist = SOQLCache.of(Profile.SObjectType)
            .whereEqual(Profile.Name, 'System Administrator')
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
            .whereEqual(Profile.Name, 'System Administrator')
            .toValueOf(Profile.Id);

        // Verify
        Assert.isNotNull(profileId, 'The System Administrator profile Id must exist.');
    }

    @IsTest
    static void toObjectWithMultipleRows() {
        // Setup
        SOQL.setMock('ProfileQuery', new List<Profile>{
            new Profile(Id = '00e3V000000Nme3QAC', Name = 'System Administrator'),
            new Profile(Id = '00e3V000000Nme3QAC', Name = 'System Administrator')
        });

        QueryException queryException = null;

        // Test
        try {
            SOQLCache.of(Profile.SObjectType)
                .mockId('ProfileQuery')
                .whereEqual(Profile.Name, 'System Administrator')
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
        SOQL.setMock('ProfileQuery', new Profile(Id = '00e3V000000Nbc3QAC', Name = 'Guest User'));

        // Test
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Guest User')
            .toObject();

        // Verify
        Assert.areEqual('00e3V000000Nbc3QAC', profile.Id, 'Record not found in cache should be retrieved from SOQL and cached.');
        Assert.areEqual('Guest User', profile.Name, 'Record not found in cache should be retrieved from SOQL and cached.');
    }

    @IsTest
    static void recordNotFoundInCacheAndNotExistInDatabase() {
        // Setup
        SOQL.setMock('ProfileQuery', new List<Profile>());

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
    static void cachedRecordDoesNotHaveNecessaryFields() {
        // Test
        Profile profile1 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        Profile profile2 = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name, Profile.UserType, Profile.UserLicenseId) // more fields
            .whereEqual(Profile.Name, 'System Administrator')
            .toObject();

        List<SOQLCache.CacheItem> cachedProfiles = (List<SOQLCache.CacheItem>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(2, Limits.getQueries(), 'Two queries should be issued. The second query should retrieve the missing fields.');

        Assert.isFalse(cachedProfiles.isEmpty(), 'The Apex transaction cache should not be empty.');
        Assert.areEqual(1, cachedProfiles.size(), 'The Apex transaction cache should contain exactly one record.');

        Assert.isTrue(profile2.isSet('Id'), 'The profile Id should not be set.');
        Assert.isTrue(profile2.isSet('Name'), 'The profile Name should not be set.');
        Assert.isTrue(profile2.isSet('UserType'), 'The profile UserType should not be set.');
        Assert.isTrue(profile2.isSet('UserLicenseId'), 'The profile UserLicenseId should not be set.');
    }

    @IsTest
    static void recordsClearedFromCache() {
        // Setup
        Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
            .with(Profile.Id, Profile.Name)
            .whereEqual(Profile.Name, 'System Administrator')
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
            .whereEqual(Profile.Name, 'System Administrator')
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

    static User minimumAccessUser() {
        return new User(
            Alias = 'newUser',
            Email = 'newuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'queryselector@testorg.com'
        );
    }

    public class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector{
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

    public class SOQL_ProfileCacheDefault extends SOQLCache implements SOQLCache.Selector{
        public SOQL_ProfileCacheDefault query() {
            return new SOQL_ProfileCacheDefault();
        }

        private SOQL_ProfileCacheDefault() {
            super(Profile.SObjectType);
            with(Profile.Id, Profile.Name, Profile.UserType);
        }
    }
}
