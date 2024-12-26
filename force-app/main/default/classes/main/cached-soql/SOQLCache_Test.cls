@IsTest
private class SOQLCache_Test {
    private static final String INITIAL_QUERY_MOCK_ID = 'cachedProfile';
    private static final List<Profile> PROFILES = new List<Profile>{
        new Profile(Id = '00e3V000000Nme3QAC', Name = 'System Administrator'),
        new Profile(Id = '00e3V000000NmefQAC', Name = 'Standard User')
    };

    @IsTest
    static void initialQuery() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        new SOQL_ProfileCache().whereEqual('Name', 'System Administrator').toObject(); // initial query will be executed
        List<Profile> cachedProfiles = (List<Profile>) CacheManager.ApexTransaction.get('ProfileTest');

        // Verify
        Assert.areEqual(PROFILES, cachedProfiles);
    }

    @IsTest
    static void noInitialQuery() {
        // Test
        new SOQL_ProfileCacheDefault().whereEqual('Name', 'System Administrator').toObject();
        List<Profile> cachedProfiles = (List<Profile>) CacheManager.ApexTransaction.get('ProfileTest');

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', cachedProfiles[0].Id);
        Assert.areEqual('System Administrator', cachedProfiles[0].Name);
    }

    @IsTest
    static void multipleSelectorInvocation() {
        // Test
        new SOQL_ProfileCache().whereEqual('Name', 'System Administrator').toObject(); // initial query will be executed
        new SOQL_ProfileCache().whereEqual('Name', 'System Administrator').toObject();
        new SOQL_ProfileCache().whereEqual('Name', 'System Administrator').toObject();
        new SOQL_ProfileCache().whereEqual('Name', 'System Administrator').toObject();

        Integer issuedQueriesAmount = Limits.getQueries();

        // Verify
        Assert.areEqual(1, issuedQueriesAmount, 'Only initial query should be executed.');
    }

    @IsTest
    static void cacheInApexTransaction() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache()
            .cacheInApexTransaction()
            .whereEqual('Name', 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
    }

    @IsTest
    static void cacheInOrgCache() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache()
            .cacheInOrgCache()
            .whereEqual('Name', 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
    }

    @IsTest
    static void cacheInSessionCache() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache()
            .cacheInSessionCache()
            .whereEqual('Name', 'System Administrator')
            .toObject();

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
    }

    @IsTest
    static void stripInaccessible() {
        // Setup
        Task task = new Task(Subject = 'Test', Type = 'Other');
        insert task;

        System.runAs(minimumAccessUser()) {
            // Test
            Task cachedTask = (Task) new SOQL_TaskCache()
                .query()
                .whereEqual('Id', task.Id)
                .stripInaccessible()
                .toObject();

            Exception queryException = null;

            String inaccessibleFieldValue;

            try {
                inaccessibleFieldValue = cachedTask.Type;
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
    static void whereEqualSObjectField() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().whereEqual(Profile.Name, 'System Administrator').toObject();

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
    }

    @IsTest
    static void whereEqualStringField() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().whereEqual('Name', 'System Administrator').toObject();

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
    }

    @IsTest
    static void whereEqualNotUniqueField() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            Profile profile = (Profile) new SOQL_ProfileCache().query().whereEqual(Profile.UserType, 'Standard').toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'Exception should be thrown when field is not Id, Name, DeveloperName or unique.');
    }

    @IsTest
    static void whereEqualNotCachedField() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            Profile profile = (Profile) new SOQL_ProfileCache().query().whereEqual(Profile.UserLicenseId, '00e3V000000NmefQAC').toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'Exception should be thrown when field is not cached.');
    }

    @IsTest
    static void cachedQueryWithoutCondition() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            Profile profile = (Profile) new SOQL_ProfileCache().query().toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'Exception should be thrown when condition is missing.');
    }

    @IsTest
    static void multipleConditions() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);
        SOQLCache.SoqlCacheException soqlException;

        // Test
        try {
            Profile profile = (Profile) new SOQL_ProfileCache().query()
                .whereEqual(Profile.Name, 'System Administrator')
                .whereEqual(Profile.Id, '00e3V000000NmefQAC')
                .toObject();
        } catch (SOQLCache.SoqlCacheException e) {
            soqlException = e;
        }

        // Verify
        Assert.isNotNull(soqlException, 'Exception should be thrown when more than 1 condition is intorduced.');
    }

    @IsTest
    static void doExist() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Boolean isProfileExist = new SOQL_ProfileCache()
            .query()
            .whereEqual(Profile.Name, 'System Administrator')
            .doExist();

        // Verify
        Assert.isTrue(isProfileExist, 'System Administrator Profile should exist.');
    }

    @IsTest
    static void toValueOf() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Id profileId = (Id) new SOQL_ProfileCache()
            .query()
            .whereEqual(Profile.Name, 'System Administrator')
            .toValueOf(Profile.Id);

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profileId);
    }

    @IsTest
    static void toObjectWithMultipleRows() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, new List<Profile>{
            new Profile(Id = '00e3V000000Nme3QAC', Name = 'System Administrator'),
            new Profile(Id = '00e3V000000NmefQAC', Name = 'System Administrator')
        });

        QueryException queryException = null;

        // Test
        try {
            Profile profile = (Profile) new SOQL_ProfileCache()
                .query()
                .whereEqual(Profile.Name, 'System Administrator')
                .toObject();
        } catch (QueryException e) {
            queryException = e;
        }

        // Verify
        Assert.isNotNull(queryException, 'QueryException should be thrown, because query has more than 1 row for assignment to SObject.');
    }

    @IsTest
    static void byId() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().byId('00e3V000000Nme3QAC');

        // Verify
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
    }

    @IsTest
    static void recordNotFoundInCache() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);
        SOQL.setMock('ProfileQuery', new Profile(Id = '00e3V000000Nbc3QAC', Name = 'Guest User'));

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query()
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Guest User')
            .toObject();

        // Verify
        Assert.areEqual('00e3V000000Nbc3QAC', profile.Id);
        Assert.areEqual('Guest User', profile.Name);
    }

    @IsTest
    static void recordNotFoundInCacheAndNotExistInDatabase() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, new List<Profile>());

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query()
            .mockId('ProfileQuery')
            .whereEqual(Profile.Name, 'Guest User Test')
            .toObject();

        // Verify
        Assert.isNull(profile);
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
        Assert.areEqual('00e3V000000Nme3QAC', profile.Id);
        Assert.areEqual('System Administrator', profile.Name);
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
        }

        public override SOQL.Queryable initialQuery() {
            return SOQL.of(Profile.SObjectType).mockId(INITIAL_QUERY_MOCK_ID).systemMode().withoutSharing();
        }

        public override List<SObjectField> cachedFields() {
            return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType};
        }
    }

    public class SOQL_ProfileCacheDefault extends SOQLCache implements SOQLCache.Selector{
        public SOQL_ProfileCacheDefault query() {
            return new SOQL_ProfileCacheDefault();
        }

        private SOQL_ProfileCacheDefault() {
            super(Profile.SObjectType);
        }

        public override List<SObjectField> cachedFields() {
            return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType};
        }
    }

    public class SOQL_TaskCache extends SOQLCache implements SOQLCache.Selector{
        public SOQL_TaskCache query() {
            return new SOQL_TaskCache();
        }

        private SOQL_TaskCache() {
            super(Task.SObjectType);
        }

        public override SOQL.Queryable initialQuery() {
            return SOQL.of(Task.SObjectType).systemMode().withoutSharing();
        }

        public override List<SObjectField> cachedFields() {
            return new List<SObjectField>{ Task.Id, Task.Type, Task.Subject };
        }
    }
}
