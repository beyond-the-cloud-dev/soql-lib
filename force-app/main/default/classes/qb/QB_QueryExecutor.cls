public inherited sharing class QB_QueryExecutor {
    private String queryIdentifier;
    private String fromObject;
    private Boolean previewQuery = false;
    private QB soqlBuilder;

    private SharingMode mode = SharingMode.INHERITED;

    public Map<String, Object> binding = new Map<String, Object>();

    private final Map<SharingMode, System.Type> MODE_TO_EXECUTOR = new Map<SharingMode, System.Type>{
        sharingMode.WITH_SHARING => WithSharing.class,
        sharingMode.WITHOUT_SHARING => WithoutSharing.class,
        sharingMode.INHERITED => InheritedSharing.class
    };

    public enum SharingMode {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    public QB_QueryExecutor(QB soqlBuilder) {
        this.soqlBuilder = soqlBuilder;
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

    public void preview() {
        System.debug('\n\n============ Query Preview ============\n' + this.getSoql() + '\n=======================================\n');
        System.debug('\n\n============ Query Variables ============\n' + JSON.SerializePretty(this.binding) + '\n=======================================\n');
    }

    public String getSoql() {
        return this.soqlBuilder.build(this);
    }

    public String bindVariable(Object variable) {
        String bindingName = 'binding' + String.valueof(this.binding.size() - 1);

        this.binding.put(bindingName, variable);

        return bindingName;
    }

    public sObject toSObject() {
        try {
            return this.toSObjectList()[0];
        } catch (ListException e) {
            return null; // List index out of bounds: 0
        }
    }

    public List<sObject> toSObjectList() {
        return this.execute(this.getSoql());
    }

    public List<sObject> execute(String soqlQuery) {
        if (QB_TestMock.contains(this.queryIdentifier)) {
            return QB_TestMock.get(this.queryIdentifier);
        }

        DatabaseQuery dq = (DatabaseQuery) MODE_TO_EXECUTOR.get(this.mode).newInstance();

        dq.setValuesToBind(this.binding);

        return dq.executeQuery(soqlQuery);
    }

    private abstract class DatabaseQuery {
        protected Map<String, Object> binding = new Map<String, Object>();

        public abstract List<sObject> executeQuery(String query);

        public void setValuesToBind(Map<String, Object> binding) {
            if (!binding.isEmpty()) {
                return;
            }

            this.binding = binding;
        }
    }

    private inherited sharing class InheritedSharing extends DatabaseQuery {
        public override List<sObject> executeQuery(String query) {
            return Database.queryWithBinds(query, binding, AccessLevel.USER_MODE);
        }
    }

    private without sharing class WithoutSharing extends DatabaseQuery {
        public override List<sObject> executeQuery(String query) {
            return Database.queryWithBinds(query, binding, AccessLevel.USER_MODE);
        }
    }

    private with sharing class WithSharing extends DatabaseQuery {
        public override List<sObject> executeQuery(String query) {
            return Database.queryWithBinds(query, binding, AccessLevel.USER_MODE);
        }
    }
}
