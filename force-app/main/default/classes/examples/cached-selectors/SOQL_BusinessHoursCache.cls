public with sharing class SOQL_BusinessHoursCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_BusinessHoursCache query() {
        return new SOQL_BusinessHoursCache();
    }

    private SOQL_BusinessHoursCache() {
        super(BusinessHours.SObjectType);
        cacheInOrgCache();
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(BusinessHours.SObjectType)
            .whereAre(SOQL.Filter.with(BusinessHours.IsActive).isTrue())
            .systemMode()
            .withoutSharing();
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ BusinessHours.Id, BusinessHours.Name };
    }

    public BusinessHours byName(String name) {
        return (BusinessHours) whereEqual(BusinessHours.Name, name).toObject();
    }
}
