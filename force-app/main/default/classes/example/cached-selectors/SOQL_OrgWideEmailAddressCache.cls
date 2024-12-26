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

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ OrgWideEmailAddress.Id, OrgWideEmailAddress.DisplayName, OrgWideEmailAddress.Address };
    }

    public OrgWideEmailAddress byAddress(String address) {
        return (OrgWideEmailAddress) whereEqual(OrgWideEmailAddress.Address, address).toObject();
    }
}
