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
        new SOQL_ProfileCache(); // initial query will be executed
        List<Profile> cachedProfiles = (List<Profile>) CacheManager.ApexTransaction.get('Profile');

        // Verify
        Assert.areEqual(PROFILES, cachedProfiles);
    }

    @IsTest
    static void whereEqualSObjectField() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().whereEqual(Profile.Name, 'System Administrator').toObject();

        // Verify
        Assert.areEqual(profile.Id, '00e3V000000Nme3QAC');
        Assert.areEqual(profile.Name, 'System Administrator');
    }

    @IsTest
    static void whereEqualStringField() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().whereEqual('Name', 'System Administrator').toObject();

        // Verify
        Assert.areEqual(profile.Id, '00e3V000000Nme3QAC');
        Assert.areEqual(profile.Name, 'System Administrator');
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
    static void byId() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().byId('00e3V000000Nme3QAC');

        // Verify
        Assert.areEqual(profile.Id, '00e3V000000Nme3QAC');
        Assert.areEqual(profile.Name, 'System Administrator');
    }

    @IsTest
    static void recordNotFoundInCache() {
        // Setup
        SOQL.setMock(INITIAL_QUERY_MOCK_ID, PROFILES);
        SOQL.setMock('ProfileQuery', new Profile(Id = '00e3V000000Nbc3QAC', Name = 'Guest User'));

        // Test
        Profile profile = (Profile) new SOQL_ProfileCache().query().mockId('ProfileQuery').whereEqual(Profile.Name, 'Guest User').toObject();

        // Verify
        Assert.areEqual(profile.Id, '00e3V000000Nbc3QAC');
        Assert.areEqual(profile.Name, 'Guest User');
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

        public override CacheManager.Cacheable cacheIn() {
            return CacheManager.ApexTransaction;
        }

        public override List<SObjectField> cachedFields() {
            return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType};
        }
    }
}
