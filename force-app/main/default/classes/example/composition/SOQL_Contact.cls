public inherited sharing class SOQL_Contact implements SOQL.Selector {
    public static SOQL query() {
        // default settings
        return new SOQL(Contact.SObjectType)
            .with(Contact.Id, Contact.Name, Contact.AccountId)
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byRecordType(String rt) {
        return query()
            .whereAre(SOQL.Filter.recordType().equal(rt));
    }

    public static SOQL byAccountId(Id accountId) {
        return query()
            .whereAre(SOQL.Filter.with(Contact.AccountId).equal(accountId));
    }

    public static String toName(Id contactId) {
        return (String) query().byId(contactId).toValueOf(Contact.Name);
    }
}
