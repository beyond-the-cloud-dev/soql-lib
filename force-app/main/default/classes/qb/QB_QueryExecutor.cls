public with sharing class QB_QueryExecutor {
    private static Map<String, List<sObject>> moduleToMockedResults = new Map<String, List<sObject>>();

    private String soqlQuery;
    private String moduleName;
    private Boolean executeWithoutSharing = false;

    @TestVisible
    private static void createMock(String moduleName, List<sObject> recordsToMock) {
        moduleToMockedResults.put(moduleName, recordsToMock);
    }

    public QB_QueryExecutor withQuery(String soqlQuery) {
        this.soqlQuery = soqlQuery;
        return this;
    }

    public QB_QueryExecutor withoutSharing() {
        this.executeWithoutSharing = true;
        return this;
    }

    public QB_QueryExecutor withTestResultMock(String moduleName) {
        this.moduleName = moduleName;
        return this;
    }

    public sObject toObject() {
        return this.toList().get(0);
    }

    public List<sObject> toList() {
        if (moduleToMockedResults.get(this.moduleName) != null && Test.isRunningTest()) {
            return moduleToMockedResults.get(this.moduleName);
        }

        if (this.executeWithoutSharing) {
            return new WithoutSharing().executeQuery(this.soqlQuery);
        }
        // default with sharing
        return new WithSharing().executeQuery(this.soqlQuery);
    }

    private without sharing class WithoutSharing {
        public List<sObject> executeQuery(String query) {
            return Database.query(query);
        }
    }

    private with sharing class WithSharing {
        public List<sObject> executeQuery(String query) {
            return Database.query(query);
        }
    }
}
