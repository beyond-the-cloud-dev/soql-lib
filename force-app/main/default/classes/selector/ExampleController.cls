public with sharing class ExampleController {

    public static List<Account> getAccounts(String accountName) {
        return AccountSelector.Query
            .field(Account.BillingCity)
            .field(Account.BillingCountry)
            .whereAre(SOQL.Condition.field(Account.Name).likeAnyBoth(accountName))
            .asList();
    }
}
