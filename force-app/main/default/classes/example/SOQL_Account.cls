public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.Type)
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byRecordType(String rt) {
        return query().whereAre(SOQL.Filter.recordType().equal(rt));
    }

    public static SOQL byIndustry(String industry) {
        return query()
            .with(Account.Industry)
            .whereAre(SOQL.Filter.with(Account.Industry).equal(industry));
    }

    public static SOQL byParentId(Id parentId) {
        return query()
            .with(Account.ParentId)
            .whereAre(SOQL.Filter.with(Account.ParentId).equal(parentId));
    }

    public static String toIndustry(Id accountId) {
        return (String) query().byId(accountId).toValueOf(Account.Industry);
    }
}
