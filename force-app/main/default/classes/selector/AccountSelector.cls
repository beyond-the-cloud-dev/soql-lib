public with sharing class AccountSelector {
    public static SOQL query {
        get {
            return SOQL.of(Account.SObjectType)
                .with(new List<SObjectField>{
                    Account.Name,
                    Account.AccountNumber
                })
                .systemMode()
                .withoutSharing();
        }
    }

    public static SOQL getByRecordType(String rt) {
        return query.with(new List<SObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
