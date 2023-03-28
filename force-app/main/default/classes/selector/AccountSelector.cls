public with sharing class AccountSelector {
    public static SOQL Query {
        get {
            return SOQL.of(Account.sObjectType).fields(new List<sObjectField>{
                Account.Name,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
        }
    }

    public static SOQL getByRecordType(String rt) {
        return Query.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.Filter.recordType().equal(rt));
    }
}
