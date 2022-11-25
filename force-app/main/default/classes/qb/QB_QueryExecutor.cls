public inherited sharing class QB_QueryExecutor {
    private String queryIdentifier;
    private String fromObject;
    private SharingMode mode = SharingMode.INHERITED;
    private Boolean previewQuery = false;

    public enum SharingMode {
        INHERITED, WITH_SHARING, WITHOUT_SHARING
    }

    public QB_QueryExecutor() {
    }

    public QB_QueryExecutor(sObjectType fromObject) {
        this.fromObject = fromObject.getDescribe().getName();
    }

    public void withSharing() {
        this.mode = SharingMode.WITH_SHARING;
    }

    public void withoutSharing() {
        this.mode = SharingMode.WITHOUT_SHARING;
    }

    public void withTestResultMock(String queryIdentifier) {
        this.queryIdentifier = queryIdentifier;
    }

    public void withPreview() {
        this.previewQuery = true;
    }

    public sObject toSObject(String soqlQuery) {
        try {
            return this.toSObjectList(soqlQuery)[0];
        } catch (ListException e) {
            return null; // List index out of bounds: 0
        }
    }

    public List<sObject> toSObjectList(String soqlQuery) {
        if (this.isPreviewActive()) {
            QB_Preview.displayQuery(soqlQuery);
            List<sObject> results = this.execute(soqlQuery);
            QB_Preview.displayResults(results);
            return results;
        }
        return this.execute(soqlQuery);
    }

    private Boolean isPreviewActive() {
        if (String.isEmpty(this.fromObject)) { // sub-query
            return false;
        }

        QueryDebugger__mdt qd = QueryDebugger__mdt.getInstance(this.fromObject);

        return this.previewQuery || (qd != null && qd.ViewQuery__c);
    }

    public List<sObject> execute(String soqlQuery) {
        if (QB_TestMock.contains(this.queryIdentifier)) {
            return QB_TestMock.get(this.queryIdentifier);
        }

        if (this.mode == sharingMode.WITH_SHARING) {
            return new WithSharing().executeQuery(soqlQuery);
        }

        if (this.mode == sharingMode.WITHOUT_SHARING) {
            return new WithoutSharing().executeQuery(soqlQuery);
        }

        return new InheritedSharing().executeQuery(soqlQuery);
    }

    private inherited sharing class InheritedSharing {
        public List<sObject> executeQuery(String query) {
            return Database.query(query);
        }
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
