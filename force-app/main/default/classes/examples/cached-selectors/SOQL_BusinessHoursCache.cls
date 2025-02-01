public with sharing class SOQL_BusinessHoursCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_BusinessHoursCache query() {
        return new SOQL_BusinessHoursCache();
    }

    private SOQL_BusinessHoursCache() {
        super(BusinessHours.SObjectType);
        cacheInOrgCache();
        with(BusinessHours.Id, BusinessHours.Name);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(BusinessHours.SObjectType).whereAre(SOQL.Filter.with(BusinessHours.IsActive).isTrue());
    }

    public SOQL_BusinessHoursCache byName(String name) {
        whereEqual(BusinessHours.Name, name);
        return this;
    }
}
