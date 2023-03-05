public inherited sharing class QS_Account extends SObjectSelector {
    public sObjectType fromSObject() {
        return Account.sObjectType;
    }

    public void globalQueryConfig() {
        qsBuilder.fields(new List<sObjectField>{
            Account.Name,
            Account.AccountNumber,
            Account.AnnualRevenue,
            Account.BillingCity,
            Account.BillingCountry,
            Account.BillingCountryCode,
            Account.BillingLongitude,
            Account.BillingPostalCode,
            Account.BillingState
        });
    }

    public Account getById(Id accountId) {
        return (Account) qsBuilder
            .whereAre(QS.ConditionGroup
                .add(QS.Condition.field(Account.Id).equal(accountId))
            )
            .preview()
            .asObject();
    }

    public List<Account> getByIds(List<Id> accountIds) {
        return (List<Account>) qsBuilder
            .whereAre(QS.ConditionGroup
                .add(QS.Condition.field(Account.Id).inCollection(accountIds))
            )
            .preview()
            .asList();
    }
}
