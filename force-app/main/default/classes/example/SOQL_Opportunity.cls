public inherited sharing class SOQL_Opportunity extends SOQL implements SOQL.Selector {
    public static SOQL_Opportunity query() {
        return new SOQL_Opportunity();
    }

    private SOQL_Opportunity() {
        super(Opportunity.SObjectType);
        // default settings
        with(Opportunity.Id, Opportunity.AccountId);
    }

    public SOQL_Opportunity byAccountId(Id accountId) {
        whereAre(Filter.with(Opportunity.AccountId).equal(accountId));
        return this;
    }

    public Integer toAmount(Id opportunityId) {
        return (Integer) query().byId(opportunityId).toValueOf(Opportunity.Amount);
    }
}
