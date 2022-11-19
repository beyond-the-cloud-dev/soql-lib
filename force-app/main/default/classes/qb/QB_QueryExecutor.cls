public with sharing class QB_QueryExecutor {

    private String soqlQuery;
    private String queryIdentifier;
    private Boolean executeWithoutSharing = false;

    public QB_QueryExecutor withQuery(String soqlQuery) {
        this.soqlQuery = soqlQuery;
        return this;
    }

    public QB_QueryExecutor withoutSharing() {
        this.executeWithoutSharing = true;
        return this;
    }

    public QB_QueryExecutor withTestResultMock(String queryIdentifier) {
        this.queryIdentifier = queryIdentifier;
        return this;
    }

    public sObject toObject() {
        return this.toList().get(0);
    }

    public List<sObject> toList() {
        if (QB_Mock.contains(this.queryIdentifier)) {
            return QB_Mock.get(this.queryIdentifier);
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
