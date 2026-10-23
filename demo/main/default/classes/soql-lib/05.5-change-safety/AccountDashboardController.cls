public with sharing class AccountDashboardController {
    private static final Integer TOP_ACCOUNTS_LIMIT = 10;

    @AuraEnabled(cacheable=true)
    public static List<Account> getTopTechnologyAccounts() {
        return SOQL_Account.query()
            .byIndustry('Technology')
            .with(Account.AnnualRevenue)
            .orderBy(Account.AnnualRevenue)
            .sortDesc()
            .setLimit(TOP_ACCOUNTS_LIMIT)
            .toList();
    }
}
