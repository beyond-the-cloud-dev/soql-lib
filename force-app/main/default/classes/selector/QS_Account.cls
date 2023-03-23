public inherited sharing class QS_Account {

    public static Query Selector {
        get {
            return Query.of(Account.sObjectType).fields(new List<sObjectField>{
                Account.Name,
                Account.AccountNumber
            })
            .systemMode()
            .withoutSharing();
        }
    }

    public static Query getByRecordType(String rtDevName) {
        return Selector.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(Query.ConditionsGroup
            .add(Query.Condition.recordTypeDeveloperName().equal(rtDevName))
        );
    }
}
