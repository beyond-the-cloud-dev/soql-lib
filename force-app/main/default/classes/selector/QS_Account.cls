public inherited sharing class QS_Account {

    public static SOQL Selector {
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
        return Selector.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(SOQL.ConditionsGroup
            .add(SOQL.Condition.recordTypeDeveloperName().equal(rtDevName))
        );
    }
}
