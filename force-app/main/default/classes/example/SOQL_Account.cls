public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    public final String MOCK_ID = 'SOQL_Account';

    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name, Account.Type);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Account byRecordType(String rt) {
        whereAre(Filter.recordType().equal(rt));
        return this;
    }

    public SOQL_Account byIndustry(String industry) {
        with(Account.Industry)
            .whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        with(Account.ParentId)
            .whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }

    public String toIndustry(Id accountId) {
        return (String) byId(accountId).toValueOf(Account.Industry);
    }
}
