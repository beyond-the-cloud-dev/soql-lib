
public inherited sharing class SOQL_Opportunity extends SOQL {
    public SOQL_Opportunity() {
        super(Opportunity.SObjectType);
        // default settings
        with(Opportunity.Id, Opportunity.AccountId)
        .systemMode()
        .withoutSharing();
    }

    public List<Opportunity> byRecordType(String rt) {
        return whereAre(Filter.recordType().equal(rt)).toList();
    }

    public List<Opportunity> byAccountId(Id accountId) {
        return with(Opportunity.AccountId).whereAre(Filter.with(Opportunity.AccountId).equal(accountId)).toList();
    }

    public Integer toAmount(Id opportunityId) {
        return (Integer) byId(opportunityId).toValueOf(Opportunity.Amount);
    }
}
