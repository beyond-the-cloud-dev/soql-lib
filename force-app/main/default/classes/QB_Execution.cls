public inherited sharing class QB_Execution {
    private enum SharingMode {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    private SharingMode mode = SharingMode.INHERITED;

    private static final Map<SharingMode, DatabaseQuery> MODE_TO_EXECUTOR = new Map<SharingMode, DatabaseQuery>{
        SharingMode.WITH_SHARING => new WithSharing(),
        SharingMode.WITHOUT_SHARING => new WithoutSharing(),
        SharingMode.INHERITED => new InheritedSharing()
    };

    public void withSharing() {
        mode = Sharingmode.WITH_SHARING;
    }

    public void withoutSharing() {
        mode = Sharingmode.WITHOUT_SHARING;
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

        //TODO Query
        String query = '';

        return MODE_TO_EXECUTOR.get(mode).execute(query, binding);
    }

    private interface DatabaseQuery {
        List<sObject> execute(String query, Map<String, Object> binding);
    }

    private inherited sharing class InheritedSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding) {
            return Database.queryWithBinds(query, binding, AccessLevel.USER_MODE);
        }
    }

    private without sharing class WithoutSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding) {
            return Database.queryWithBinds(query, binding, AccessLevel.USER_MODE);
        }
    }

    private with sharing class WithSharing implements DatabaseQuery {
        public List<sObject> execute(String query, Map<String, Object> binding) {
            return Database.queryWithBinds(query, binding, AccessLevel.USER_MODE);
        }
    }
}
