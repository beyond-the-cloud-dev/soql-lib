public with sharing class ReferenceDataService {
    private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';

    public static Boolean isSandbox() {
        return SOQL_CachedOrganization.isSandbox();
    }

    public static Id getSystemAdminProfileId() {
        return SOQL_CachedProfile.query().byName(SYSTEM_ADMINISTRATOR_PROFILE).toId();
    }
}
