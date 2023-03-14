public with sharing class ExampleController {

    public static List<Account> getAccounts() {
        return (List<Account>) QS_Account.Selector
            .fields(new List<sObjectField>{
                Account.BillingCity,
                Account.BillingCountry,
                Account.BillingCountryCode
            })
            .whereAre(QS.ConditionsGroup
                .add(QS.Condition.field(Account.Id).equal('0013V00000WNCw4QAH'))
                .add(QS.Condition.field(Account.Name).likeAnyBoth(accountName))
                .order('1 OR 2')
             )
            .asList();
    }
}
select id from account limit 10
