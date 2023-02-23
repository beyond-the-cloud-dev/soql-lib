public inherited sharing class QBE {
    private enum SharingLevel {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    private SharingLevel sharingMode = SharingLevel.INHERITED;
    private AccessLevel accessMode = AccessLevel.USER_MODE;

    private String query;

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

    public QBE evaluate(String query) {
        this.query = query;
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
        //TODO return mock if there is mock

        //TODO Binding
        Map<String, Object> binding = new Map<String, Object>();

        return MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode);
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
