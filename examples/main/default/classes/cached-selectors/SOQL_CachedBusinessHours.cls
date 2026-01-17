public without sharing class SOQL_CachedBusinessHours extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedBusinessHours query() {
        return new SOQL_CachedBusinessHours();
    }

    private SOQL_CachedBusinessHours() {
        super(BusinessHours.SObjectType);
        cacheInOrgCache();
        with(BusinessHours.Id, BusinessHours.Name);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(BusinessHours.SObjectType).whereAre(SOQL.Filter.with(BusinessHours.IsActive).isTrue());
    }

    public SOQL_CachedBusinessHours byName(String name) {
        whereEqual(BusinessHours.Name, name);
        return this;
    }
}
