public without sharing class SOQL_CachedOrgWideEmailAddress extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedOrgWideEmailAddress query() {
        return new SOQL_CachedOrgWideEmailAddress();
    }

    private SOQL_CachedOrgWideEmailAddress() {
        super(OrgWideEmailAddress.SObjectType);
        with(OrgWideEmailAddress.Id, OrgWideEmailAddress.DisplayName, OrgWideEmailAddress.Address);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(OrgWideEmailAddress.SObjectType);
    }

    public override List<SObjectField> additionalAllowedConditionFields() {
        return new List<SObjectField>{ OrgWideEmailAddress.Address };
    }

    public SOQL_CachedOrgWideEmailAddress byAddress(String address) {
        whereEqual(OrgWideEmailAddress.Address, address);
        return this;
    }
}
