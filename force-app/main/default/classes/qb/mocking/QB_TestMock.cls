public with sharing class QB_TestMock {
    private static Map<String, List<sObject>> queryIdentifierToMockedResults = new Map<String, List<sObject>>();

    public static void setMock(String queryIdentifier, QB_Mock mock) {
        queryIdentifierToMockedResults.put(queryIdentifier, mock.records());
    }

    public static Boolean contains(String queryIdentifier) {
        if (!Test.isRunningTest()) {
            return false;
        }
        return queryIdentifierToMockedResults.containsKey(queryIdentifier);
    }

    public static List<sObject> get(String queryIdentifier) {
        if (!Test.isRunningTest()) {
            return null;
        }
        return queryIdentifierToMockedResults.get(queryIdentifier);
    }
}
