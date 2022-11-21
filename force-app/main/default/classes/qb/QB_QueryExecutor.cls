public with sharing class QB_QueryExecutor {

    private String queryIdentifier;
    private Boolean executeWithoutSharing = false;

    public void withoutSharing() {
        this.executeWithoutSharing = true;
    }

    public void withTestResultMock(String queryIdentifier) {
        this.queryIdentifier = queryIdentifier;
    }

    public sObject toObject(String soqlQuery) {
        try {
            return this.toList(soqlQuery)[0];
        } catch (Exception e) {
            return null; // List index out of bounds: 0
        }
    }

    public List<sObject> toList(String soqlQuery) {
        if (QB_TestMock.contains(this.queryIdentifier)) {
            return QB_TestMock.get(this.queryIdentifier);
        }

        if (this.executeWithoutSharing) {
            return new WithoutSharing().executeQuery(soqlQuery);
        }
        // default with sharing
        return new WithSharing().executeQuery(soqlQuery);
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
