public with sharing class AccountSelector implements SOQL.Selector {
    public static SOQL query() {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                 Account.Name,
                 Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
    }

    public static SOQL byRecordType(String rt) {
        return query().with(new List<SObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
