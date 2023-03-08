public inherited sharing class QB_Executor {
    private enum SharingLevel {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    private SharingLevel sharingMode = SharingLevel.INHERITED;
    private AccessLevel accessMode = AccessLevel.USER_MODE;

    private String query;
    private String queryIdentifier;
    private Boolean withPreview = false;
    private Boolean isCountQuery = false;
    private Map<String, Object> binding;

    private static final Map<SharingLevel, DatabaseQuery> MODE_TO_EXECUTOR = new Map<SharingLevel, DatabaseQuery>{
        SharingLevel.WITH_SHARING => new WithSharing(),
        SharingLevel.WITHOUT_SHARING => new WithoutSharing(),
        SharingLevel.INHERITED => new InheritedSharing()
    };

    public void withSharing() {
        sharingMode = SharingLevel.WITH_SHARING;
    }

    public void withoutSharing() {
        sharingMode = SharingLevel.WITHOUT_SHARING;
    }

    public void systemMode() {
        accessMode = AccessLevel.SYSTEM_MODE;
    }

    public void mocking(String identifier) {
        queryIdentifier = identifier;
    }

    public void countQuery() {
        isCountQuery = true;
    }

    public void preview() {
        withPreview = true;
    }

    public QB_Executor evaluate(String query, Map<String, Object> binding) {
        this.query = query;
        this.binding = binding;
        return this;
    }

    public sObject asObject() {
        try {
            return asList()[0];
        } catch (ListException e) {
            return null; // List index out of bounds: 0
        }
    }

    public Integer asInteger() {
        if (withPreview) {
            previewSoql();
            previewBinding();
        }

        if (QS_Mock.containsCountMock(queryIdentifier)) {
            return QS_Mock.getCountMock(queryIdentifier);
        }

        return MODE_TO_EXECUTOR.get(sharingMode).executeCount(query, binding, accessMode);
    }

    public List<sObject> asList() {
        if (withPreview) {
            previewSoql();
            previewBinding();
        }

        if (QS_Mock.containsMock(queryIdentifier)) {
            return QS_Mock.getMock(queryIdentifier);
        }

        return MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode);
    }

    private void previewSoql() {
        System.debug('\n\n============ Query Preview ============\n' + query + '\n=======================================\n');
    }

    private void previewBinding() {
        System.debug('\n\n============ Query Binding ============\n' + JSON.serializePretty(binding) + '\n=======================================\n');
    }

    private interface DatabaseQuery {
        List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel);
        Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel);
    }

    private inherited sharing class InheritedSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private without sharing class WithoutSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private with sharing class WithSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }
}
