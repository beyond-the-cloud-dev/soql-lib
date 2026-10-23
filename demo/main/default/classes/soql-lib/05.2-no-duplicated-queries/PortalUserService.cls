public with sharing class PortalUserService {
    public static List<PortalUser__c> getUsers(Set<Id> userIds) {
        return SOQL_PortalUser.query().byIds(userIds).toList();
    }

    public static PortalUser__c getUser(Id userId) {
        return (PortalUser__c) SOQL_PortalUser.query().byId(userId).toObject();
    }

    public static List<PortalUser__c> getAllUsers() {
        return SOQL_PortalUser.query().toList();
    }

    public static PortalUser__c getUserBySsoId(String ssoId) {
        return (PortalUser__c) SOQL_PortalUser.query().bySsoId(ssoId).toObject();
    }

    public static String getDisplayName(Id userId) {
        return SOQL_PortalUser.query().toDisplayName(userId);
    }
}
