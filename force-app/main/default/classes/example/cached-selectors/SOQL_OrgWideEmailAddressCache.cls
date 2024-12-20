public with sharing class SOQL_OrgWideEmailAddressCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_OrgWideEmailAddressCache query() {
        return new SOQL_OrgWideEmailAddressCache();
    }

    private SOQL_OrgWideEmailAddressCache() {
        super(OrgWideEmailAddress.SObjectType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(OrgWideEmailAddress.SObjectType).systemMode().withoutSharing();
    }

    public override StorageType cacheIn() {
        return StorageType.ORG_CACHE;
    }

    public override List<SObjectField> cachedBy() {
        return new List<SObjectField>{ OrgWideEmailAddress.Address };
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ OrgWideEmailAddress.Id, OrgWideEmailAddress.DisplayName, OrgWideEmailAddress.Address };
    }

    public OrgWideEmailAddress byAddress(String address) {
        whereAre(SOQLCache.Filter.with(OrgWideEmailAddress.Address).equal(address));
        return (OrgWideEmailAddress) toObject();
    }
}
