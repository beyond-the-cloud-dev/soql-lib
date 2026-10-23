public inherited sharing class SOQL_PortalUser extends SOQL implements SOQL.Selector {
    public static SOQL_PortalUser query() {
        return new SOQL_PortalUser();
    }

    private SOQL_PortalUser() {
        super(PortalUser__c.SObjectType);
        with(PortalUser__c.Id, PortalUser__c.SSOId__c, PortalUser__c.FirstName__c, PortalUser__c.LastName__c, PortalUser__c.DisplayName__c);
    }

    public SOQL_PortalUser bySsoId(String ssoId) {
        whereAre(Filter.with(PortalUser__c.SSOId__c).equal(ssoId));
        return this;
    }

    public String toDisplayName(Id userId) {
        return (String) byId(userId).toValueOf(PortalUser__c.DisplayName__c);
    }
}
