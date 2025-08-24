public inherited sharing class SOQL_Contact extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'SOQL_Contact';

    public static SOQL_Contact query() {
        return new SOQL_Contact();
    }

    private SOQL_Contact() {
        super(Contact.SObjectType);
        // default settings
        with(Contact.Id, Contact.Name, Contact.AccountId);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Contact byEmail(String email) {
        whereAre(Filter.with(Contact.Email).equal(email));
        return this;
    }

    public SOQL_Contact byAccountId(Id accountId) {
        whereAre(Filter.with(Contact.AccountId).equal(accountId));
        return this;
    }

    public SOQL_Contact byOwnerId(Id ownerId) {
        whereAre(Filter.with(Contact.OwnerId).equal(ownerId));
        return this;
    }
}
