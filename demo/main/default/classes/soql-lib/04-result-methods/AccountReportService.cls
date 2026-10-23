public with sharing class AccountReportService {
    private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    private static final String PARTNER_RECORD_TYPE = 'Partner';

    public static Set<String> getAccountNames() {
        return SOQL.of(Account.SObjectType).toValuesOf(Account.Name);
    }

    public static Map<String, String> getAccountIdByContactId() {
        return SOQL.of(Contact.SObjectType).toMap(Contact.Id, Contact.AccountId);
    }

    public static Set<Id> getAccountOwnerIds() {
        return SOQL.of(Account.SObjectType).toIdsOf(Account.OwnerId);
    }

    public static Id getSystemAdminProfileId() {
        return SOQL.of(Profile.SObjectType)
            .whereAre(SOQL.Filter.with(Profile.Name).equal(SYSTEM_ADMINISTRATOR_PROFILE))
            .toId();
    }

    public static Boolean hasPartnerAccounts() {
        return SOQL.of(Account.SObjectType).byRecordType(PARTNER_RECORD_TYPE).doExist();
    }

    public static Map<String, List<SObject>> getAccountsByIndustry() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Name, Account.Industry)
            .toAggregatedMap(Account.Industry);
    }
}
