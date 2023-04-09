public with sharing class AccountSelector {
    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType).with(new List<SObjectField>{
                Account.Name,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
        }
    }

    public static SOQL getByRecordType(String rt) {
        return Query.with(new List<SObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
