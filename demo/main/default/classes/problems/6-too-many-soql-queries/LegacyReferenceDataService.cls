public with sharing class LegacyReferenceDataService {
    private static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';

    public static Boolean isSandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static Id getSystemAdminProfileId() {
        return [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE LIMIT 1].Id;
    }
}
