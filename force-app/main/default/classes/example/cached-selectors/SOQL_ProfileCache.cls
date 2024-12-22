public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
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

    public Profile byId(Id profileId) {
        return (Profile) whereAre(Filter.with(Profile.Id).equal(profileId)).toObject();
    }

    public Profile byName(String name) {
        return (Profile) whereAre(Filter.with(Profile.Name).equal(name)).toObject();
    }
}
