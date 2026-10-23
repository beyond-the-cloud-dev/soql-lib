public with sharing class AccountController {
    private static final String PARTNER_RECORD_TYPE = 'Partner';

    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .whereAre(SOQL.Filter.recordType().equal(PARTNER_RECORD_TYPE))
            .mockId('AccountController.getPartnerAccounts')
            .toList();
    }

    public static Account getPartnerAccount(String accountName) {
        return (Account) SOQL_Account.query()
            .whereAre(SOQL.Filter.name().equal(accountName))
            .whereAre(SOQL.Filter.recordType().equal(PARTNER_RECORD_TYPE))
            .mockId('AccountController.getPartnerAccount')
            .toObject();
    }

    public static Integer countPartnerAccounts() {
        return SOQL_Account.query()
            .whereAre(SOQL.Filter.recordType().equal(PARTNER_RECORD_TYPE))
            .mockId('AccountController.countPartnerAccounts')
            .toInteger();
    }
}
