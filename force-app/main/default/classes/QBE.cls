public inherited sharing class QBE {
    private enum SharingLevel {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    private SharingLevel sharingMode = SharingLevel.INHERITED;
    private AccessLevel accessMode = AccessLevel.USER_MODE;

    private String query;
    private Boolean withPreview = false;
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

    public void preview() {
        withPreview = true;
    }

    public QBE evaluate(String query, Map<String, Object> binding) {
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

    public List<sObject> asList() {
        if (withPreview) {
            previewSoql();
            previewBinding();
        }

        //TODO return mock if there is mock

        return MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode);
    }

    private void previewSoql() {
        System.debug('\n\n============ Query Preview ============\n' + this.query + '\n=======================================\n');
    }

    private void previewBinding() {
        System.debug('\n\n============ Query Binding ============\n' + JSON.serializePretty(this.binding) + '\n=======================================\n');
    }

    private interface DatabaseQuery {
        List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel);
    }

    private inherited sharing class InheritedSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }
    }

    private without sharing class WithoutSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }
    }

    private with sharing class WithSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }
    }
}
