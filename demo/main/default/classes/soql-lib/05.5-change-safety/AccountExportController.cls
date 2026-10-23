public with sharing class AccountExportController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getPartnerAccountsForExport() {
        return SOQL_Account.query()
            .byType('Partner')
            .with(Account.BillingCity, Account.BillingCountry, Account.Website)
            .toList();
    }
}
