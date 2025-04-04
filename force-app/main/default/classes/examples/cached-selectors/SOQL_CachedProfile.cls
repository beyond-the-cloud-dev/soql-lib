public with sharing class SOQL_CachedProfile extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedProfile query() {
        return new SOQL_CachedProfile();
    }

    private SOQL_CachedProfile() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        with(Profile.Id, Profile.Name, Profile.UserType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType);
    }

    public SOQL_CachedProfile byName(String name) {
        whereEqual(Profile.Name, name);
        return this;
    }
}
