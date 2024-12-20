public with sharing class SOQL_BusinessHoursCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_BusinessHoursCache query() {
        return new SOQL_BusinessHoursCache();
    }

    private SOQL_BusinessHoursCache() {
        super(BusinessHours.SObjectType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(BusinessHours.SObjectType)
            .whereAre(SOQL.Filter.with(BusinessHours.IsActive).isTrue())
            .systemMode()
            .withoutSharing();
    }

    public override StorageType cacheIn() {
        return StorageType.ORG_CACHE;
    }

    public override List<SObjectField> cachedBy() {
        return new List<SObjectField>{ BusinessHours.Name };
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ BusinessHours.Id, BusinessHours.Name };
    }

    public BusinessHours byName(String name) {
        whereAre(SOQLCache.Filter.with(BusinessHours.Name).equal(name));
        return (BusinessHours) toObject();
    }
}
