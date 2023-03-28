public inherited sharing class SOQL implements Queryable {

    public static SubQuery Sub {
        get {
            return new SubQuery(binder);
        }
    }

    public static FiltersGroup FiltersGroup {
        get {
            return new FiltersGroup(false);
        }
    }

    public static Filter Filter {
        get {
            return new Filter(binder);
        }
    }

    public static JoinQuery InnerJoin {
        get {
            return new JoinQuery(binder);
        }
    }

    @TestVisible
    private static void setMock(String queryIdentifier, List<sObject> records) {
        mocks.put(queryIdentifier, records);
    }

    @TestVisible
    private static void setCountMock(String queryIdentifier, Integer amount) {
        countMocks.put(queryIdentifier, amount);
    }

    public interface Queryable {
        SOQL of(sObjectType ofObject);

        SOQL field(sObjectField field);
        SOQL fields(List<sObjectField> fields);
        SOQL fields(String commaSeparatedFields);
        SOQL relatedFields(String relationshipPath, List<sObjectField> fields);
        SOQL count();
        SOQL countAs(sObjectField field, String alias);

        SOQL subQuery(SubQuery subQuery); //Sub

        SOQL delegatedScope();
        SOQL mineScope();
        SOQL mineAndMyGroupsScope();
        SOQL myTerritoryScope();
        SOQL myTeamTerritoryScope();
        SOQL teamScope();

        SOQL whereAre(ConditionClause conditions); //SOQL.FiltersGroup or SOQL.Filter

        SOQL groupBy(sObjectField field);
        SOQL groupByRollup(sObjectField field);

        SOQL orderBy(sObjectField field);
        SOQL orderByRelated(String path, sObjectField field);
        SOQL sortDesc();
        SOQL nullsLast();

        SOQL setLimit(Integer amount);

        SOQL offset(Integer startingRow);

        SOQL forReference();
        SOQL forView();
        SOQL forUpdate();
        SOQL allRows();

        SOQL systemMode();

        SOQL withSharing();
        SOQL withoutSharing();

        SOQL mocking(String queryIdentifier);

        SOQL preview();

        SOQL stripInaccessible();
        SOQL stripInaccessible(AccessType accessType);

        sObject asObject();
        List<sObject> asList();
        List<AggregateResult> asAggregated();
        Integer asInteger();
    }

    public interface SoqlSubQuery { //SOQL.Sub
        SubQuery of(String ofObject);

        SubQuery fields(List<sObjectField> fields);
        SubQuery relatedFields(String relationshipPath, List<sObjectField> fields);

        SubQuery whereAre(ConditionClause conditions); //SOQL.FiltersGroup or SOQL.Filter

        SubQuery orderBy(sObjectField field);
        SubQuery orderByRelated(String path, sObjectField field);
        SubQuery sortDesc();
        SubQuery nullsLast();

        SubQuery setLimit(Integer amount);

        SubQuery offset(Integer startingRow);

        SubQuery forReference();
        SubQuery forView();
    }

    public interface SoqlCondition { //SOQL.Filter
        Filter id();
        Filter recordType();
        Filter field(SObjectField field);
        Filter field(String field);
        Filter relatedField(String relationshipPath, SObjectField field);

        Filter isNull();
        Filter isNotNull();
        Filter equal(Object value);
        Filter notEqual(Object value);
        Filter lessThan(Object value);
        Filter greaterThan(Object value);
        Filter lessThanOrEqual(Object value);
        Filter greaterThanOrEqual(Object value);
        Filter likeAny(String value);
        Filter likeAnyLeft(String value);
        Filter likeAnyRight(String value);
        Filter isIn(List<Object> inList);
        Filter isNotIn(List<Object> inList);
        Filter isIn(JoinQuery joinQuery); //SOQL.JoinQuery
        Filter isNotIn(JoinQuery joinQuery); //SOQL.JoinQuery
    }

    public interface SoqlFiltersGroup { //SOQL.FiltersGroup
        FiltersGroup add(ConditionClause condition); //SOQL.Filter or SOQL.FiltersGroup
        FiltersGroup order(String order);
    }

    public interface SoqlJoin { //SOQL.InnerJoin
        JoinQuery of(sObjectType ofObject);

        JoinQuery field(sObjectField field);

        JoinQuery whereAre(ConditionClause conditions); //SOQL.Filter or SOQL.FiltersGroup
    }

    // Implementation details

    private static Binder binder;

    private QB builder;
    private Executor executor;

    private static Map<String, List<sObject>> mocks = new Map<String, List<sObject>>();
    private static Map<String, Integer> countMocks = new Map<String, Integer>();

    public static SOQL of(sObjectType ofObject) {
        return new SOQL(ofObject);
    }

    private SOQL(sObjectType ofObject) {
        binder = new Binder();
        builder = new QB(ofObject);
        executor = new Executor();
    }

    // Fields

    public SOQL field(sObjectField field) {
        builder.fields.retrive(field);
        return this;
    }

    public SOQL fields(List<sObjectField> fields) {
        builder.fields.retrive(fields);
        return this;
    }

    public SOQL fields(String commaSeparatedFields) {
        builder.fields.retrive(commaSeparatedFields);
        return this;
    }

    public SOQL relatedFields(String relationshipPath, List<sObjectField> fields) {
        builder.fields.retrive(relationshipPath, fields);
        return this;
    }

    public SOQL count() {
        builder.fields.count();
        executor.countQuery();
        return this;
    }

    public SOQL countAs(sObjectField field, String alias) {
        builder.fields.count(field, alias);
        executor.countQuery();
        return this;
    }

    // SubQuery

    public SOQL subQuery(SubQuery subQuery) {
        builder.subQueries.add(subQuery);
        return this;
    }

    // Scope

    public SOQL delegatedScope() {
        builder.scope.delegated();
        return this;
    }

    public SOQL mineScope() {
        builder.scope.mine();
        return this;
    }

    public SOQL mineAndMyGroupsScope() {
        builder.scope.mineAndMyGroups();
        return this;
    }

    public SOQL myTerritoryScope() {
        builder.scope.myTerritory();
        return this;
    }

    public SOQL myTeamTerritoryScope() {
        builder.scope.myTeamTerritory();
        return this;
    }

    public SOQL teamScope() {
        builder.scope.team();
        return this;
    }

    // Where

    public SOQL whereAre(ConditionClause conditions) {
        builder.conditions.add(conditions);
        return this;
    }

    // Group By

    public SOQL groupBy(sObjectField field) {
        builder.groupBy.field(field);
        return this;
    }

    public SOQL groupByRollup(sObjectField field) {
        builder.groupBy.rollup(field);
        return this;
    }

    // Order By - ASC, NULLS FIRST by default

    public SOQL orderBy(sObjectField field) {
        builder.orderBys.add(field);
        return this;
    }

    public SOQL orderByRelated(String path, sObjectField field) {
        builder.orderBys.add(path, field);
        return this;
    }

    public SOQL sortDesc() {
        builder.orderBy.sortDesc();
        return this;
    }

    public SOQL nullsLast() {
        builder.orderBy.nullsLast();
        return this;
    }

    // Limit

    public SOQL setLimit(Integer amount) {
        builder.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public SOQL offset(Integer startingRow) {
        builder.soqlOffset.offset(startingRow);
        return this;
    }

    // For

    public SOQL forReference() {
        builder.soqlFor.forReference();
        return this;
    }

    public SOQL forView() {
        builder.soqlFor.forView();
        return this;
    }

    public SOQL forUpdate() {
        builder.soqlFor.forUpdate();
        return this;
    }

    public SOQL allRows() {
        builder.soqlFor.allRows();
        return this;
    }

    // FLS - User Mode by default

    public SOQL systemMode() {
        executor.systemMode();
        return this;
    }

    // Sharing - inherited sharing by default

    public SOQL withSharing() {
        executor.withSharing();
        return this;
    }

    public SOQL withoutSharing() {
        executor.withoutSharing();
        return this;
    }

    // Mocking

    public SOQL mocking(String queryIdentifier) {
        executor.mocking(queryIdentifier);
        return this;
    }

    // Debug

    public SOQL preview() {
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

    public SOQL stripInaccessible() {
        return stripInaccessible(AccessType.READABLE);
    }

    public SOQL stripInaccessible(AccessType accessType) {
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

    public SOQL getById(Id recordId) {
        return whereAre(Filter.id().equal(recordId));
    }

    public SOQL getByIds(List<Id> recordIds) {
        return whereAre(Filter.id().isIn(recordIds));
    }

    // Config

    public interface QueryClause {
        String build();
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

        public FiltersGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new FiltersGroup(true));
                }
                return (FiltersGroup) clauses[4];
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

     // SubQuery

     public class SubQuery implements QueryClause, SoqlSubQuery {
        private QB builder;
        private Binder binder;

        public SubQuery(Binder binder) {
            this.binder = binder;
        }

        public SubQuery of(String ofObject) { // FROM
            builder = new QB(ofObject);
            return this;
        }

        public SubQuery fields(List<sObjectField> fields) { // SELECT
            builder.fields.retrive(fields);
            return this;
        }

        public SubQuery relatedFields(String relationshipPath, List<sObjectField> fields) { // SELECT
            builder.fields.retrive(relationshipPath, fields);
            return this;
        }

        public SubQuery whereAre(ConditionClause conditions) { // WHERE
            builder.conditions.add(conditions);
            return this;
        }

        // ORDER BY - ASC, NULLS FIRST by default

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

        public SubQuery setLimit(Integer amount) { // LIMIT
            builder.soqlLimit.max(amount);
            return this;
        }

        public SubQuery offset(Integer startingRow) { // OFFSER
            builder.soqlOffset.offset(startingRow);
            return this;
        }

        // FOR

        public SubQuery forReference() {
            builder.soqlFor.forReference();
            return this;
        }

        public SubQuery forView() {
            builder.soqlFor.forView();
            return this;
        }

        public String build() {
            return builder.build();
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

    public interface ConditionClause {
        String build();
    }

    public class FiltersGroup implements ConditionClause, QueryClause, SoqlFiltersGroup {
        private List<ConditionClause> queryConditions = new List<ConditionClause>();
        private String order = '';
        private String connector = 'AND';
        private Boolean isParent = false;

        public FiltersGroup(Boolean isParent) {
            this.isParent = isParent;
        }

        public FiltersGroup add(ConditionClause condition) {
            queryConditions.add(condition);
            return this;
        }

        public FiltersGroup byAND() {
            connector = 'AND';
            return this;
        }

        public FiltersGroup byOR() {
            connector = 'OR';
            return this;
        }

        public FiltersGroup order(String order) {
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

    public class Filter implements ConditionClause, SoqlCondition {
        private String field;
        private String comperator;
        private Object value;
        private Binder binder;
        private JoinQuery joinQuery;

        public Filter(Binder binder) {
            this.binder = binder;
        }

        public Filter id() {
            return field('Id');
        }

        public Filter recordType() {
            return field('RecordType.DeveloperName');
        }

        public Filter field(SObjectField field) {
            return field(field.getDescribe().getName());
        }

        public Filter relatedField(String relationshipPath, SObjectField field) {
            return field(relationshipPath + '.' + field.getDescribe().getName());
        }

        public Filter field(String field) {
            this.field = field;
            return this;
        }

        public Filter isNull() {
            return equal(null);
        }

        public Filter isNotNull() {
            return notEqual(null);
        }

        public Filter equal(Object value) {
            return set('=', value);
        }

        public Filter notEqual(Object value) {
            return set('!=', value);
        }

        public Filter lessThan(Object value) {
            return set('<', value);
        }

        public Filter greaterThan(Object value) {
            return set('>', value);
        }

        public Filter lessThanOrEqual(Object value) {
            return set('<=', value);
        }

        public Filter greaterThanOrEqual(Object value) {
            return set('>=', value);
        }

        public Filter likeAny(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()) + '%');
        }

        public Filter likeAnyLeft(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()));
        }

        public Filter likeAnyRight(String value) {
            return set('LIKE', String.escapeSingleQuotes(value.trim()) + '%');
        }

        public Filter isIn(List<Object> inList) {
            return set('IN', inList);
        }

        public Filter isNotIn(List<Object> inList) {
            return set('NOT IN', inList);
        }

        private Filter set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public Filter isIn(JoinQuery joinQuery) {
            return set('IN', joinQuery);
        }

        public Filter isNotIn(JoinQuery joinQuery) {
            return set('NOT IN', joinQuery);
        }

        private Filter set(String comperator, JoinQuery joinQuery) {
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

    public class JoinQuery implements QueryClause, SoqlJoin {
        private QB builder;
        private Binder binder;

        public JoinQuery(Binder binder) {
            this.binder = binder;
        }

        public JoinQuery of(sObjectType ofObject) { // FROM
            builder = new QB(ofObject);
            return this;
        }

        public JoinQuery field(sObjectField field) { // SELECT
            builder.fields.retrive(field);
            return this;
        }

        public JoinQuery whereAre(ConditionClause condition) { // WHERE
            builder.conditions.add(condition);
            return this;
        }

        public String build() {
            return builder.build();
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

        public void offset(Integer fromRow) {
            soqlOffset = fromRow;
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

        public void systemMode() { // The object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the sharingMode.
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
            System.debug('\n\n============ SOQL Preview ============\n' + query + '\n=======================================\n');
        }

        private void previewBinding() {
            System.debug('\n\n============ SOQL Binding ============\n' + JSON.serializePretty(binding) + '\n=======================================\n');
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
