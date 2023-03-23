public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return QS_Account.Selector
            .field(Account.BillingCity)
            .field(Account.BillingCountry)
            .whereAre(Query.Condition.field(Account.Name).likeAnyBoth(accountName))
            .asList();
    }
}