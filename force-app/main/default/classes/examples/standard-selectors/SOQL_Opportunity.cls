public inherited sharing class SOQL_Opportunity extends SOQL implements SOQL.Selector {
    public static final String MOCK_ID = 'SOQL_Opportunity';

    public static SOQL_Opportunity query() {
        return new SOQL_Opportunity();
    }

    private SOQL_Opportunity() {
        super(Opportunity.SObjectType);
        // default settings
        with(Opportunity.Id, Opportunity.AccountId);
        mockId(MOCK_ID);
    }

    public SOQL_Opportunity isNotClosed() {
        whereAre(Filter.with(Opportunity.IsClosed).isFalse());
        return this;
    }

    public SOQL_Opportunity isWon() {
        whereAre(Filter.with(Opportunity.IsWon).isTrue());
        return this;
    }

    public SOQL_Opportunity byAccountId(Id accountId) {
        whereAre(Filter.with(Opportunity.AccountId).equal(accountId));
        return this;
    }

    public SOQL_Opportunity byContactId(Id contactId) {
        whereAre(Filter.with(Opportunity.ContactId).equal(contactId));
        return this;
    }

    public SOQL_Opportunity byStageName(Id stageName) {
        whereAre(Filter.with(Opportunity.StageName).equal(stageName));
        return this;
    }
}
