public inherited sharing class Query implements Querable {

    public static SubQuery Sub {
        get {
            return new SubQuery(binder);
        }
    }

    public static ConditionsGroup ConditionsGroup {
        get {
            return new ConditionsGroup(false);
        }
    }

    public static Condition Condition {
        get {
            return new Condition(binder);
        }
    }

    public static JoinQuery InnerJoin {
        get {
            return new JoinQuery(binder);
        }
    }

    public interface Querable {
        Query of(sObjectType ofObject);

        Query field(sObjectField field);
        Query fields(List<sObjectField> fields);
        Query fields(String commaSeparatedFields);
        Query relatedFields(String relationshipPath, List<sObjectField> fields);
        Query count();
        Query countAs(sObjectField field, String alias);

        Query subQuery(SubQuery subQuery); //Sub

        Query delegatedScope();
        Query mineScope();
        Query mineAndMyGroupsScope();
        Query myTerritoryScope();
        Query myTeamTerritoryScope();
        Query teamScope();

        Query whereAre(ConditionClause conditions); //Query.ConditionsGroup or Query.Condition

        Query groupBy(sObjectField field);
        Query groupByRollup(sObjectField field);

        Query orderBy(sObjectField field);
        Query orderByRelated(String path, sObjectField field);
        Query sortDesc();
        Query nullsLast();

        Query setLimit(Integer amount);

        Query offset(Integer startingRow);

        Query forReference();
        Query forView();
        Query forUpdate();
        Query allRows();

        Query systemMode();

        Query withSharing();
        Query withoutSharing();

        Query mocking(String queryIdentifier);
        void setMock(String queryIdentifier, List<sObject> records);
        void setCountMock(String queryIdentifier, Integer amount);

        Query preview();

        Query stripInaccessible();
        Query stripInaccessible(AccessType accessType);

        sObject asObject();
        List<sObject> asList();
        List<AggregateResult> asAggregated();
        Integer asInteger();
    }

    public interface SoqlSubQuery {
        SubQuery of(String ofObject);

        SubQuery fields(List<sObjectField> fields);
        SubQuery relatedFields(String relationshipPath, List<sObjectField> fields);

        SubQuery whereAre(ConditionClause conditions); //Query.ConditionsGroup or Query.Condition

        SubQuery orderBy(sObjectField field);
        SubQuery orderByRelated(String path, sObjectField field);
        SubQuery sortDesc();
        SubQuery nullsLast();

        SubQuery setLimit(Integer amount);

        SubQuery offset(Integer startingRow);

        SubQuery forReference();
        SubQuery forView();
    }

    public interface SoqlCondition {
        Condition id();
        Condition recordTypeDeveloperName();
        Condition field(SObjectField field);
        Condition field(String field);
        Condition relatedField(String relationshipPath, SObjectField field);

        Condition isNull();
        Condition isNotNull();
        Condition equal(Object value);
        Condition notEqual(Object value);
        Condition lessThan(Object value);
        Condition greaterThan(Object value);
        Condition lessThanOrEqual(Object value);
        Condition greaterThanOrEqual(Object value);
        Condition likeAnyBoth(String value);
        Condition likeAnyLeft(String value);
        Condition likeAnyRight(String value);
        Condition isIn(List<Object> inList);
        Condition isNotIn(List<Object> inList);
        Condition isIn(JoinQuery joinQuery); //Query.JoinQuery
        Condition isNotIn(JoinQuery joinQuery); //Query.JoinQuery
    }

    public interface SoqlConditionsGroup {
        ConditionsGroup add(ConditionClause condition); //Query.Condition or Query.ConditionsGroup
        ConditionsGroup order(String order);
    }

    public interface SoqlJoin {
        JoinQuery of(sObjectType ofObject);

        JoinQuery field(sObjectField field);

        JoinQuery whereAre(ConditionClause conditions); //ConditionsGroup or Condition
    }

    // Implementation details

    private static Binder binder;

    private QB builder;
    private Executor executor;

    private static Map<String, List<sObject>> mocks = new Map<String, List<sObject>>();
    private static Map<String, Integer> countMocks = new Map<String, Integer>();

    public static Query of(sObjectType ofObject) {
        return new Query(ofObject);
    }

    private Query(sObjectType ofObject) {
        binder = new Binder();
        builder = new QB(ofObject);
        executor = new Executor();
    }

    // Fields

    public Query field(sObjectField field) {
        builder.fields.retrive(field);
        return this;
    }

    public Query fields(List<sObjectField> fields) {
        builder.fields.retrive(fields);
        return this;
    }

    public Query fields(String commaSeparatedFields) {
        builder.fields.retrive(commaSeparatedFields);
        return this;
    }

    public Query relatedFields(String relationshipPath, List<sObjectField> fields) {
        builder.fields.retrive(relationshipPath, fields);
        return this;
    }

    public Query count() {
        builder.fields.count();
        executor.countQuery();
        return this;
    }

    public Query countAs(sObjectField field, String alias) {
        builder.fields.count(field, alias);
        executor.countQuery();
        return this;
    }

    // SubQuery

    public Query subQuery(SubQuery subQuery) {
        builder.subQueries.add(subQuery);
        return this;
    }

    // Scope

    public Query delegatedScope() {
        builder.scope.delegated();
        return this;
    }

    public Query mineScope() {
        builder.scope.mine();
        return this;
    }

    public Query mineAndMyGroupsScope() {
        builder.scope.mineAndMyGroups();
        return this;
    }

    public Query myTerritoryScope() {
        builder.scope.myTerritory();
        return this;
    }

    public Query myTeamTerritoryScope() {
        builder.scope.myTeamTerritory();
        return this;
    }

    public Query teamScope() {
        builder.scope.team();
        return this;
    }

    // Where

    public Query whereAre(ConditionClause conditions) {
        builder.conditions.add(conditions);
        return this;
    }

    // Group By

    public Query groupBy(sObjectField field) {
        builder.groupBy.field(field);
        return this;
    }

    public Query groupByRollup(sObjectField field) {
        builder.groupBy.rollup(field);
        return this;
    }

    // Order By - ASC, NULLS FIRST by default

    public Query orderBy(sObjectField field) {
        builder.orderBys.add(field);
        return this;
    }

    public Query orderByRelated(String path, sObjectField field) {
        builder.orderBys.add(path, field);
        return this;
    }

    public Query sortDesc() {
        builder.orderBy.sortDesc();
        return this;
    }

    public Query nullsLast() {
        builder.orderBy.nullsLast();
        return this;
    }

    // Limit

    public Query setLimit(Integer amount) {
        builder.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public Query offset(Integer startingRow) {
        builder.soqlOffset.fromRow(startingRow);
        return this;
    }

    // For

    public Query forReference() {
        builder.soqlFor.forReference();
        return this;
    }

    public Query forView() {
        builder.soqlFor.forView();
        return this;
    }

    public Query forUpdate() {
        builder.soqlFor.forUpdate();
        return this;
    }

    public Query allRows() {
        builder.soqlFor.allRows();
        return this;
    }

    // FLS - User Mode by default

    public Query systemMode() {
        executor.systemMode();
        return this;
    }

    // Sharing - inherited sharing by default

    public Query withSharing() {
        executor.withSharing();
        return this;
    }

    public Query withoutSharing() {
        executor.withoutSharing();
        return this;
    }

    // Mocking

    public Query mocking(String queryIdentifier) {
        executor.mocking(queryIdentifier);
        return this;
    }

    public static void setMock(String queryIdentifier, List<sObject> records) {
        mocks.put(queryIdentifier, records);
    }

    public static void setCountMock(String queryIdentifier, Integer amount) {
        countMocks.put(queryIdentifier, amount);
    }

    public static List<sObject> getMock(String queryIdentifier) {
        return mocks.get(queryIdentifier);
    }

    public static Integer getCountMock(String queryIdentifier) {
        return countMocks.get(queryIdentifier);
    }

    public static Boolean containsMock(String queryIdentifier) {
        return mocks.get(queryIdentifier) != null;
    }

    public static Boolean containsCountMock(String queryIdentifier) {
        return countMocks.get(queryIdentifier) != null;
    }

    // Debug

    public Query preview() {
        executor.preview();
        return this;
    }

    public String soql() {
        return builder.build();
    }

    public Map<String, Object> binding() {
        return binder.build();
    }

    // Result

    public Query stripInaccessible() {
        return stripInaccessible(AccessType.READABLE);
    }

    public Query stripInaccessible(AccessType accessType) {
        executor.stripInaccessible(accessType);
        return this;
    }

    public sObject asObject() {
        return executor.evaluate(builder.build(), binder.build()).asObject();
    }

    public List<sObject> asList() {
        return executor.evaluate(builder.build(), binder.build()).asList();
    }

    public List<AggregateResult> asAggregated() {
        return (List<AggregateResult>) asList();
    }

    public Integer asInteger() {
        return executor.evaluate(builder.build(), binder.build()).asInteger();
    }

    // Standard

    public Query getById(Id recordId) {
        return whereAre(Condition.id().equal(recordId));
    }

    public Query getByIds(List<Id> recordIds) {
        return whereAre(Condition.id().isIn(recordIds));
    }

    // Config

    public interface QueryClause {
        String build();
    }

    public interface ConditionClause {
        String build();
    }

    // SubQuery

    public class SubQuery implements QueryClause, SoqlSubQuery {
        private QB builder;
        private Binder binder;

        public SubQuery(Binder binder) {
            this.binder = binder;
        }

        // From

        public SubQuery of(String ofObject) {
            builder = new QB(ofObject);
            return this;
        }

        // Fields

        public SubQuery fields(List<sObjectField> fields) {
            builder.fields.retrive(fields);
            return this;
        }

        public SubQuery relatedFields(String relationshipPath, List<sObjectField> fields) {
            builder.fields.retrive(relationshipPath, fields);
            return this;
        }

        // Where

        public SubQuery whereAre(ConditionClause conditions) {
            builder.conditions.add(conditions);
            return this;
        }

        // Order By - ASC, NULLS FIRST by default

        public SubQuery orderBy(sObjectField field) {
            builder.orderBys.add(field);
            return this;
        }

        public SubQuery orderByRelated(String path, sObjectField field) {
            builder.orderBys.add(path, field);
            return this;
        }

        public SubQuery sortDesc() {
            builder.orderBy.sortDesc();
            return this;
        }

        public SubQuery nullsLast() {
            builder.orderBy.nullsLast();
            return this;
        }

        // Limit

        public SubQuery setLimit(Integer amount) {
            builder.soqlLimit.max(amount);
            return this;
        }

        // Offset

        public SubQuery offset(Integer startingRow) {
            builder.soqlOffset.fromRow(startingRow);
            return this;
        }

        // For

        public SubQuery forReference() {
            builder.soqlFor.forReference();
            return this;
        }

        public SubQuery forView() {
            builder.soqlFor.forView();
            return this;
        }

        // Build

        public String build() {
            return builder.build();
        }
    }

    public class Condition implements ConditionClause, SoqlCondition {
        private String field;
        private String comperator;
        private Object value;
        private Binder binder;
        private JoinQuery joinQuery;

        public Condition(Binder binder) {
            this.binder = binder;
        }

        public Condition id() {
            return field('Id');
        }

        public Condition recordTypeDeveloperName() {
            return field('RecordType.DeveloperName');
        }

        public Condition field(SObjectField field) {
            return field(field.getDescribe().getName());
        }

        public Condition relatedField(String relationshipPath, SObjectField field) {
            return field(relationshipPath + '.' + field.getDescribe().getName());
        }

        public Condition field(String field) {
            this.field = field;
            return this;
        }

        public Condition isNull() {
            return equal(null);
        }

        public Condition isNotNull() {
            return notEqual(null);
        }

        public Condition equal(Object value) {
            return set('=', value);
        }

        public Condition notEqual(Object value) {
            return set('!=', value);
        }

        public Condition lessThan(Object value) {
            return set('<', value);
        }

        public Condition greaterThan(Object value) {
            return set('>', value);
        }

        public Condition lessThanOrEqual(Object value) {
            return set('<=', value);
        }

        public Condition greaterThanOrEqual(Object value) {
            return set('>=', value);
        }

        public Condition likeAnyBoth(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()) + '%');
        }

        public Condition likeAnyLeft(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()));
        }

        public Condition likeAnyRight(String value) {
            return set('LIKE', String.escapeSingleQuotes(value.trim()) + '%');
        }

        public Condition isIn(List<Object> inList) {
            return set('IN', inList);
        }

        public Condition isNotIn(List<Object> inList) {
            return set('NOT IN', inList);
        }

        private Condition set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public Condition isIn(JoinQuery joinQuery) {
            return set('IN', joinQuery);
        }

        public Condition isNotIn(JoinQuery joinQuery) {
            return set('NOT IN', joinQuery);
        }

        private Condition set(String comperator, JoinQuery joinQuery) {
            this.joinQuery = joinQuery;
            this.comperator = comperator;
            return this;
        }

        public String build() {
            if (joinQuery != null) {
                return field + ' ' + comperator + ' (' + joinQuery.build() + ')';
            }

            return field + ' ' + comperator + ' :' + binder.bind(value);
        }
    }

    public class ConditionsGroup implements ConditionClause, QueryClause, SoqlConditionsGroup {
        private List<ConditionClause> queryConditions = new List<ConditionClause>();
        private String order = '';
        private String connector = 'AND';
        private Boolean isParent = false;

        public ConditionsGroup(Boolean isParent) {
            this.isParent = isParent;
        }

        public ConditionsGroup add(ConditionClause condition) {
            queryConditions.add(condition);
            return this;
        }

        public ConditionsGroup byAND() {
            connector = 'AND';
            return this;
        }

        public ConditionsGroup byOR() {
            connector = 'OR';
            return this;
        }

        public ConditionsGroup order(String order) {
            this.order = order;
            return this;
        }

        public String build() {
            if (String.isEmpty(order)) {
                setDefaultOrder();
            }

            if (isParent) {
                return 'WHERE ' + buildNested();
            }

            return buildNested();
        }

        private void setDefaultOrder() {
            List<String> defaultOrder = new List<String>();

            for (Integer i = 0; i < queryConditions.size(); i++) {
                defaultOrder.add(String.valueOf(i + 1));
            }

            order = String.join(defaultOrder, ' ' + connector + ' '); // e.g (1 AND 2 AND 3)
        }

        public String buildNested() {
            String conditions = addSpecialCharactersToOrder(order); // e.g (*1* AND (*2* OR *3*))

            for (Integer i = 0; i < queryConditions.size(); i++) {
                conditions = conditions.replace(
                    addSpecialCharacters(String.valueOf(i + 1)), // e.g *1*
                    queryConditions.get(i).build()
                );
            }

            return conditions;
        }

        private String addSpecialCharactersToOrder(String order) {
            String formattedOrder = order;

            for (Integer i = 0; i < queryConditions.size(); i++) {
                String conditionNumber = String.valueOf(i + 1);

                formattedOrder = formattedOrder.replace(conditionNumber, addSpecialCharacters(conditionNumber));
            }

            if (isParent) {
                return formattedOrder;
            }

            return '(' + formattedOrder + ')'; // e.g (*1* AND (*2* OR *3*))
        }

        private String addSpecialCharacters(String condition) {
            return '*' + condition.trim() + '*';
        }
    }

    public class JoinQuery implements QueryClause, SoqlJoin {
        private QB builder;
        private Binder binder;

        public JoinQuery(Binder binder) {
            this.binder = binder;
        }

        // From

        public JoinQuery of(sObjectType ofObject) {
            builder = new QB(ofObject);
            return this;
        }

        // Fields

        public JoinQuery field(sObjectField field) {
            builder.fields.retrive(field);
            return this;
        }

        // Where

        public JoinQuery whereAre(ConditionClause condition) {
            builder.conditions.add(condition);
            return this;
        }

        // Helper

        public String build() {
            return builder.build();
        }
    }

    public class QB implements QueryClause {
        private List<QueryClause> clauses = new QueryClause[10];

        public QB(sObjectType ofObject) {
            this(ofObject.getDescribe().getName());
        }

        public QB(String ofObject) {
            clauses.set(0, new QFields());
            clauses.set(2, new QFrom(ofObject));
        }

        public QFields fields {
            get {
                return (QFields) clauses[0];
            }
        }

        public QSubQueries subQueries {
            get {
                if (clauses[1] == null) {
                    clauses.set(1, new QSubQueries());
                }
                return (QSubQueries) clauses[1];
            }
        }

        public QScope scope {
            get {
                if (clauses[3] == null) {
                    clauses.set(3, new QScope());
                }
                return (QScope) clauses[3];
            }
        }

        public ConditionsGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new ConditionsGroup(true));
                }
                return (ConditionsGroup) clauses[4];
            }
        }

        public QGroupBy groupBy {
            get {
                if (clauses[5] == null) {
                    clauses.set(5, new QGroupBy());
                }
                return (QGroupBy) clauses[5];
            }
        }

        public QOrderBy orderBy {
            get {
                return orderBys.recentOrderBy();
            }
        }

        public QOrderBys orderBys {
            get {
                if (clauses[6] == null) {
                    clauses.set(6, new QOrderBys());
                }
                return (QOrderBys) clauses[6];
            }
        }

        public QLimit soqlLimit {
            get {
                if (clauses[7] == null) {
                    clauses.set(7, new QLimit());
                }
                return (QLimit) clauses[7];
            }
        }

        public QOffset soqlOffset {
            get {
                if (clauses[8] == null) {
                    clauses.set(8, new QOffset());
                }
                return (QOffset) clauses[8];
            }
        }

        public QFor soqlFor {
            get {
                if (clauses[9] == null) {
                    clauses.set(9, new QFor());
                }
                return (QFor) clauses[9];
            }
        }

        public String build() {
            List<String> soqlParts = new List<String>();

            for (QueryClause clause : clauses) {
                if (clause == null) {
                    continue;
                }
                soqlParts.add(clause.build());
            }

            return String.join(new List<String>(soqlParts), ' ');
        }
    }

    public class QFields implements QueryClause {
        private Set<String> queryFields = new Set<String>();

        public void count() {
            queryFields.add('COUNT()');
        }

        public void count(sObjectField field, String alias) {
            queryFields.add('COUNT(' + field.getDescribe().getName() + ') ' + alias);
        }

        public void retrive(String fields) {
            for (String field : fields.deleteWhitespace().split(',')) {
                queryFields.add(field);
            }
        }

        public void retrive(List<sObjectField> fields) {
            for (sObjectField field : fields) {
                retrive(field);
            }
        }

        public void retrive(sObjectField field) {
            queryFields.add(field.getDescribe().getName());
        }

        public void retrive(String relationshipPath, List<sObjectField> fields) {
            for (sObjectField field : fields) {
                retrive(relationshipPath, field);
            }
        }

        public void retrive(String relationshipPath, sObjectField field) {
            queryFields.add(relationshipPath + '.' + field.getDescribe().getName());
        }

        public String build() {
            if (queryFields.isEmpty()) {
                return 'SELECT Id';
            }
            return 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        }
    }

    public class QSubQueries implements QueryClause {
        private List<SubQuery> subQueries = new List<SubQuery>();

        public void add(SubQuery subQuery) {
            subQueries.add(subQuery);
        }

        public String build() {
            List<String> subQueriesSoql = new List<String>();

            for (SubQuery sub : subQueries) {
                subQueriesSoql.add('(' + sub.build() + ')');
            }

            return ', ' + String.join(subQueriesSoql, ', ');
        }
    }

    public class QFrom implements QueryClause {
        private String objectApiName;

        public QFrom(String objectType) {
            objectApiName = objectType;
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    public class QScope implements QueryClause {
        private String scope = 'EVERYTHING';

        public void delegated() {
            scope = 'DELEGATED';
        }

        public void mine() {
            scope = 'MINE';
        }

        public void mineAndMyGroups() {
            scope = 'MINE_AND_MY_GROUPS';
        }

        public void myTerritory() {
            scope = 'MY_TERRITORY';
        }

        public void myTeamTerritory() {
            scope = 'MY_TEAM_TERRITORY';
        }

        public void team() {
            scope = 'TEAM';
        }

        public String build() {
            return 'USING SCOPE ' + scope;
        }
    }

    public class QGroupBy implements QueryClause {
        private Set<String> groupByFields = new Set<String>();

        public void field(sObjectField field) {
            groupByFields.add(field.getDescribe().getName());
        }

        public void rollup(sObjectField field) {
            groupByFields.add('ROLLUP(' + field.getDescribe().getName() + ')');
        }

        public String build() {
            return 'GROUP BY ' + String.join(new List<String>(groupByFields), ', ');
        }
    }

    public class QOrderBys implements QueryClause {
        public List<QOrderBy> orderBys = new List<QOrderBy>();

        public void add(sObjectField field) {
            orderBys.add(new QOrderBy().field(field));
        }

        public void add(String relationshipPath, sObjectField field) {
            orderBys.add(new QOrderBy().relatedField(relationshipPath, field));
        }

        public QOrderBy recentOrderBy() {
            return orderBys.get(orderBys.size() - 1);
        }

        public String build() {
            List<String> orderFields = new List<String>();

            for (QOrderBy orderBy : orderBys) {
                orderFields.add(orderBy.build());
            }

            return 'ORDER BY ' + String.join(orderFields, ', ');
        }
    }

    public class QOrderBy implements QueryClause {
        private String orderField;
        private String sortingOrder = 'ASC';
        private String nullsOrder = 'FIRST';

        public QOrderBy field(sObjectField field) {
            orderField = field.getDescribe().getName();
            return this;
        }

        public QOrderBy relatedField(String relationshipPath, sObjectField field) {
            orderField = relationshipPath + '.' + field.getDescribe().getName();
            return this;
        }

        public void sortDesc() {
            sortingOrder = 'DESC';
        }

        public void nullsLast() {
            nullsOrder = 'LAST';
        }

        public String build() {
            return orderField + ' ' + sortingOrder + ' NULLS ' + nullsOrder;
        }
    }

    public class QLimit implements QueryClause {
        private Integer soqlLimit = 50000;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QOffset implements QueryClause {
        private Integer soqlOffset = 2000;

        public void fromRow(Integer soqlOffset) {
            this.soqlOffset = soqlOffset;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    public class QFor implements QueryClause {
        private String forStatement;

        public void forReference() {
            forStatement = 'FOR REFERENCE';
        }

        public void forView() {
            forStatement = 'FOR VIEW';
        }

        public void forUpdate() {
            forStatement = 'FOR UPDATE';
        }

        public void allRows() {
            forStatement = 'ALL ROWS';
        }

        public String build() {
            return forStatement;
        }
    }

    public class Binder {
        private Integer bindIndex = 0;
        private Map<String, Object> binding = new Map<String, Object>();

        public String bind(Object value) {
            bindIndex++;

            binding.put('v' + bindIndex, value);

            return 'v' + bindIndex;
        }

        public Map<String, Object> build() {
            return binding;
        }
    }

    private enum SharingLevel {
        INHERITED,
        WITH_SHARING,
        WITHOUT_SHARING
    }

    public inherited sharing class Executor {
        private SharingLevel sharingMode = SharingLevel.INHERITED;
        private AccessLevel accessMode = AccessLevel.USER_MODE; // The object permissions, field-level security, and sharing rules of the current user are enforced.
        private AccessType accessType;

        private String query;
        private String queryIdentifier;
        private Boolean withPreview = false;
        private Boolean isCountQuery = false;
        private Map<String, Object> binding;

        private final Map<SharingLevel, DatabaseQuery> MODE_TO_EXECUTOR = new Map<SharingLevel, DatabaseQuery>{
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

        public void stripInaccessible(AccessType type) {
            accessType = type;
        }

        public void systemMode() {
            // The object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the sharingMode.
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

        public Executor evaluate(String query, Map<String, Object> binding) {
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

            if (countMocks.containsKey(queryIdentifier)) {
                return countMocks.get(queryIdentifier);
            }

            return MODE_TO_EXECUTOR.get(sharingMode).executeCount(query, binding, accessMode);
        }

        public List<sObject> asList() {
            if (withPreview) {
                previewSoql();
                previewBinding();
            }

            if (mocks.containsKey(queryIdentifier)) {
                return mocks.get(queryIdentifier);
            }

            if (accessType == null) {
                return MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode);
            }

            return Security.stripInaccessible(
                accessType,
                MODE_TO_EXECUTOR.get(sharingMode).execute(query, binding, accessMode)
            ).getRecords();
        }

        private void previewSoql() {
            System.debug('\n\n============ Query Preview ============\n' + query + '\n=======================================\n');
        }

        private void previewBinding() {
            System.debug('\n\n============ Query Binding ============\n' + JSON.serializePretty(binding) + '\n=======================================\n');
        }
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