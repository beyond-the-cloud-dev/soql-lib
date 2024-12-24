public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }

    public override CacheManager.Cacheable cacheIn() {
        return CacheManager.SOQLOrgCache;
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType };
    }

    public Profile byName(String name) {
        return (Profile) whereAre(Filter.with(Profile.Name).equal(name)).toObject();
        return (Profile) whereEqual(Profile.Name, name).toObject();
    }
}

Profile prof = SOQL_ProfileCache.query().byName('System Administrator');
System.debug(LoggingLevel.DEBUG, 'prof: ' + JSON.SerializePretty(prof));
System.debug(LoggingLevel.DEBUG, ': ' + JSON.SerializePretty(CacheManager.SOQLOrgCache.get('Profile')));
