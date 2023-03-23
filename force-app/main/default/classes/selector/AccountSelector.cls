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

    public static SOQL getByRecordType(String rtDevName) {
        return Query.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.ConditionsGroup
            .add(SOQL.Condition.recordTypeDeveloperName().equal(rtDevName))
        );
    }
}
