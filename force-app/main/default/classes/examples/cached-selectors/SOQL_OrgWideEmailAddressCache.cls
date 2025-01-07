public with sharing class SOQL_OrgWideEmailAddressCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_OrgWideEmailAddressCache query() {
        return new SOQL_OrgWideEmailAddressCache();
    }

    private SOQL_OrgWideEmailAddressCache() {
        super(OrgWideEmailAddress.SObjectType);
        with(OrgWideEmailAddress.Id, OrgWideEmailAddress.DisplayName, OrgWideEmailAddress.Address);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(OrgWideEmailAddress.SObjectType);
    }

    public SOQL_OrgWideEmailAddressCache byAddress(String address) {
        whereEqual(OrgWideEmailAddress.Address, address);
        return this;
    }
}
