public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'SOQL_Account';

    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        // default settings
        with(Account.Id, Account.Name);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Account byType(String type) {
        whereAre(Filter.with(Account.Type).equal(type));
        return this;
    }

    public SOQL_Account byIndustry(String industry) {
        whereAre(Filter.with(Account.Industry).equal(industry));
        return this;
    }

    public SOQL_Account byParentId(Id parentId) {
        whereAre(Filter.with(Account.ParentId).equal(parentId));
        return this;
    }

    public SOQL_Account byOwnerId(Id ownerId) {
        whereAre(Filter.with(Account.OwnerId).equal(ownerId));
        return this;
    }
}
