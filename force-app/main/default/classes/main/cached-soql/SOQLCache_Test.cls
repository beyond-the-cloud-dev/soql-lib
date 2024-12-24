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
            return new List<SObjectField>{ Profile.Id, Profile.Name };
        }
    }
}
