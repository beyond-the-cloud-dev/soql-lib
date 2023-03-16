public inherited sharing class QS_Account {

    public static QS Selector {
        get {
            return QS.of(Account.sObjectType).fields(new List<sObjectField>{
                Account.Name,
                Account.AccountNumber
            });
        }
    }

    public static QS getByRecordType(String rtDevName) {
        return Selector.fields(new List<sObjectField>{
            Account.BillingCity,
            Account.BillingCountry
        }).whereAre(QS.ConditionsGroup
            .add(QS.Condition.recordTypeDeveloperName().equal(rtDevName))
        );
    }
}
