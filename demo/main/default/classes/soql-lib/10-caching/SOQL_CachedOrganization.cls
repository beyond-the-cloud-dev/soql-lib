public without sharing class SOQL_CachedOrganization extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedOrganization query() {
        return new SOQL_CachedOrganization();
    }

    private SOQL_CachedOrganization() {
        super(Organization.SObjectType);
        cacheInOrgCache();
        with(Organization.Id, Organization.IsSandbox);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Organization.SObjectType);
    }

    public static Boolean isSandbox() {
        return (Boolean) query().byId(UserInfo.getOrganizationId()).toValueOf(Organization.IsSandbox);
    }
}
