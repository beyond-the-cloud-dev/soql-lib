public inherited sharing class SOQL_Account implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.AccountNumber)
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byRecordType(String rt) {
        return query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
