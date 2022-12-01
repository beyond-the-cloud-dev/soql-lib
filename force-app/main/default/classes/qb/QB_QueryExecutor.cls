public inherited sharing class QB_QueryExecutor {
    private String queryIdentifier;
    private String fromObject;
    private Boolean previewQuery = false;
    private QB soqlBuilder;

    private SharingMode mode = SharingMode.INHERITED;

    public List<Object> valuesToBind = new List<Object>();

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
        System.debug('\n\n============ Query Preview ============\n\n' + this.getSoql() + '\n=======================================\n');
    }

    public String getSoql() {
        return this.soqlBuilder.build(this);
    }

    public String bindVariable(Object variable) {
        this.valuesToBind.add(variable);

        return 'binding' + String.valueof(this.valuesToBind.size() - 1);
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

        dq.setValuesToBind(this.valuesToBind);

        return dq.executeQuery(soqlQuery);
    }

    private abstract class DatabaseQuery {
        protected Object binding0;
        protected Object binding1;
        protected Object binding2;
        protected Object binding3;
        protected Object binding4;
        protected Object binding5;
        protected Object binding6;
        protected Object binding7;
        protected Object binding8;
        protected Object binding9;

        public abstract List<sObject> executeQuery(String query);

        public void setValuesToBind(List<Object> valuesToBind) {
            if (!valuesToBind.isEmpty()) {
                return;
            }

            valuesToBind.addAll(new List<Object>(10 - valuesToBind.size()));

            this.binding0 = valuesToBind.get(0);
            this.binding1 = valuesToBind.get(1);
            this.binding2 = valuesToBind.get(2);
            this.binding3 = valuesToBind.get(3);
            this.binding4 = valuesToBind.get(4);
            this.binding5 = valuesToBind.get(5);
            this.binding6 = valuesToBind.get(6);
            this.binding7 = valuesToBind.get(7);
            this.binding8 = valuesToBind.get(8);
            this.binding9 = valuesToBind.get(9);
        }
    }

    private inherited sharing class InheritedSharing extends DatabaseQuery {
        public override List<sObject> executeQuery(String query) {
            return Database.query(query);
        }
    }

    private without sharing class WithoutSharing extends DatabaseQuery {
        public override List<sObject> executeQuery(String query) {
            return Database.query(query);
        }
    }

    private with sharing class WithSharing extends DatabaseQuery {
        public override List<sObject> executeQuery(String query) {
            return Database.query(query);
        }
    }
}
