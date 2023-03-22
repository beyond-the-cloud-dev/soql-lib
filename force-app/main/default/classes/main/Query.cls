public inherited sharing class Query implements Querable {

    public static Query.QB_Sub Sub {
        get {
            return new Query.QB_Sub(binder);
        }
    }

    public static Query.QB_ConditionsGroup ConditionsGroup {
        get {
            return new Query.QB_ConditionsGroup(false);
        }
    }

    public static Query.QB_Condition Condition {
        get {
            return new Query.QB_Condition(binder);
        }
    }

    public static Query.QB_Join InnerJoin {
        get {
            return new Query.QB_Join(binder);
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

        Query subQuery(QB_Sub subQuery); //Query.Sub

        Query delegatedScope();
        Query mineScope();
        Query mineAndMyGroupsScope();
        Query myTerritoryScope();
        Query myTeamTerritoryScope();
        Query teamScope();

        Query whereAre(QB_ConditionClause conditions); //Query.ConditionsGroup or Query.Condition

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
        Query.QB_Sub of(String ofObject);

        Query.QB_Sub fields(List<sObjectField> fields);
        Query.QB_Sub relatedFields(String relationshipPath, List<sObjectField> fields);

        Query.QB_Sub whereAre(QB_ConditionClause conditions); //Query.ConditionsGroup or Query.Condition

        Query.QB_Sub orderBy(sObjectField field);
        Query.QB_Sub orderByRelated(String path, sObjectField field);
        Query.QB_Sub sortDesc();
        Query.QB_Sub nullsLast();

        Query.QB_Sub setLimit(Integer amount);

        Query.QB_Sub offset(Integer startingRow);

        Query.QB_Sub forReference();
        Query.QB_Sub forView();
    }

    public interface SoqlCondition {
        Query.QB_Condition id();
        Query.QB_Condition recordTypeDeveloperName();
        Query.QB_Condition field(SObjectField field);
        Query.QB_Condition field(String field);
        Query.QB_Condition relatedField(String relationshipPath, SObjectField field);

        Query.QB_Condition isNull();
        Query.QB_Condition isNotNull();
        Query.QB_Condition equal(Object value);
        Query.QB_Condition notEqual(Object value);
        Query.QB_Condition lessThan(Object value);
        Query.QB_Condition greaterThan(Object value);
        Query.QB_Condition lessThanOrEqual(Object value);
        Query.QB_Condition greaterThanOrEqual(Object value);
        Query.QB_Condition likeAnyBoth(String value);
        Query.QB_Condition likeAnyLeft(String value);
        Query.QB_Condition likeAnyRight(String value);
        Query.QB_Condition isIn(List<Object> inList);
        Query.QB_Condition isNotIn(List<Object> inList);
        Query.QB_Condition isIn(Query.QB_Join joinQuery); //Query.JoinQuery
        Query.QB_Condition isNotIn(Query.QB_Join joinQuery); //Query.JoinQuery
    }

    public interface SoqlConditionsGroup {
        Query.QB_ConditionsGroup add(QB_ConditionClause condition); //Query.Condition or Query.QB_ConditionsGroup
        Query.QB_ConditionsGroup order(String order);
    }

    public interface SoqlJoin {
        Query.QB_Join of(sObjectType ofObject);

        Query.QB_Join field(sObjectField field);

        Query.QB_Join whereAre(QB_ConditionClause conditions); //Query.ConditionsGroup or Query.Condition
    }

    // Implementation details

    private static QB_Binder binder;

    private QB builder;
    private QB_Executor executor;

    private static Map<String, List<sObject>> mocks = new Map<String, List<sObject>>();
    private static Map<String, Integer> countMocks = new Map<String, Integer>();

    public static Query of(sObjectType ofObject) {
        return new Query(ofObject);
    }

    private Query(sObjectType ofObject) {
        binder = new QB_Binder();
        builder = new QB(ofObject);
        executor = new QB_Executor();
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

    public Query subQuery(Query.QB_Sub subQuery) {
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

    public Query whereAre(QB_ConditionClause conditions) {
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
        return whereAre(Query.Condition.id().equal(recordId));
    }

    public Query getByIds(List<Id> recordIds) {
        return whereAre(Query.Condition.id().isIn(recordIds));
    }

    // Config

    public interface QB_Part {
        String build();
    }

    public interface QB_ConditionClause {
        String build();
    }

    // SubQuery

    public class QB_Sub implements QB_Part, SoqlSubQuery {
        private QB builder;
        private QB_Binder binder;

        public QB_Sub(QB_Binder binder) {
            this.binder = binder;
        }

        // From

        public QB_Sub of(String ofObject) {
            builder = new QB(ofObject);
            return this;
        }

        // Fields

        public QB_Sub fields(List<sObjectField> fields) {
            builder.fields.retrive(fields);
            return this;
        }

        public QB_Sub relatedFields(String relationshipPath, List<sObjectField> fields) {
            builder.fields.retrive(relationshipPath, fields);
            return this;
        }

        // Where

        public QB_Sub whereAre(QB_ConditionClause conditions) {
            builder.conditions.add(conditions);
            return this;
        }

        // Order By - ASC, NULLS FIRST by default

        public QB_Sub orderBy(sObjectField field) {
            builder.orderBys.add(field);
            return this;
        }

        public QB_Sub orderByRelated(String path, sObjectField field) {
            builder.orderBys.add(path, field);
            return this;
        }

        public QB_Sub sortDesc() {
            builder.orderBy.sortDesc();
            return this;
        }

        public QB_Sub nullsLast() {
            builder.orderBy.nullsLast();
            return this;
        }

        // Limit

        public QB_Sub setLimit(Integer amount) {
            builder.soqlLimit.max(amount);
            return this;
        }

        // Offset

        public QB_Sub offset(Integer startingRow) {
            builder.soqlOffset.fromRow(startingRow);
            return this;
        }

        // For

        public QB_Sub forReference() {
            builder.soqlFor.forReference();
            return this;
        }

        public QB_Sub forView() {
            builder.soqlFor.forView();
            return this;
        }

        // Build

        public String build() {
            return builder.build();
        }
    }

    public class QB_Condition implements Query.QB_ConditionClause, Query.SoqlCondition {
        private String field;
        private String comperator;
        private Object value;
        private QB_Binder binder;
        private QB_Join joinQuery;

        public QB_Condition(QB_Binder binder) {
            this.binder = binder;
        }

        public QB_Condition id() {
            return field('Id');
        }

        public QB_Condition recordTypeDeveloperName() {
            return field('RecordType.DeveloperName');
        }

        public QB_Condition field(SObjectField field) {
            return field(field.getDescribe().getName());
        }

        public QB_Condition relatedField(String relationshipPath, SObjectField field) {
            return field(relationshipPath + '.' + field.getDescribe().getName());
        }

        public QB_Condition field(String field) {
            this.field = field;
            return this;
        }

        public QB_Condition isNull() {
            return equal(null);
        }

        public QB_Condition isNotNull() {
            return notEqual(null);
        }

        public QB_Condition equal(Object value) {
            return set('=', value);
        }

        public QB_Condition notEqual(Object value) {
            return set('!=', value);
        }

        public QB_Condition lessThan(Object value) {
            return set('<', value);
        }

        public QB_Condition greaterThan(Object value) {
            return set('>', value);
        }

        public QB_Condition lessThanOrEqual(Object value) {
            return set('<=', value);
        }

        public QB_Condition greaterThanOrEqual(Object value) {
            return set('>=', value);
        }

        public QB_Condition likeAnyBoth(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()) + '%');
        }

        public QB_Condition likeAnyLeft(String value) {
            return set('LIKE', '%' + String.escapeSingleQuotes(value.trim()));
        }

        public QB_Condition likeAnyRight(String value) {
            return set('LIKE', String.escapeSingleQuotes(value.trim()) + '%');
        }

        public QB_Condition isIn(List<Object> inList) {
            return set('IN', inList);
        }

        public QB_Condition isNotIn(List<Object> inList) {
            return set('NOT IN', inList);
        }

        private QB_Condition set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public QB_Condition isIn(Query.QB_Join joinQuery) {
            return set('IN', joinQuery);
        }

        public QB_Condition isNotIn(Query.QB_Join joinQuery) {
            return set('NOT IN', joinQuery);
        }

        private QB_Condition set(String comperator, Query.QB_Join joinQuery) {
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

    public class QB_ConditionsGroup implements Query.QB_ConditionClause, Query.QB_Part, Query.SoqlConditionsGroup {
        private List<Query.QB_ConditionClause> queryConditions = new List<QB_ConditionClause>();
        private String order = '';
        private Boolean isParent = false;

        public QB_ConditionsGroup(Boolean isParent) {
            this.isParent = isParent;
        }

        public Query.QB_ConditionsGroup add(QB_ConditionClause condition) {
            queryConditions.add(condition);
            return this;
        }

        public Query.QB_ConditionsGroup order(String order) {
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

            order = String.join(defaultOrder, ' AND '); // e.g (1 AND 2 AND 3)
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

    public class QB_Join implements QB_Part, SoqlJoin {
        private QB builder;
        private QB_Binder binder;

        public QB_Join(QB_Binder binder) {
            this.binder = binder;
        }

        // From

        public QB_Join of(sObjectType ofObject) {
            builder = new QB(ofObject);
            return this;
        }

        // Fields

        public QB_Join field(sObjectField field) {
            builder.fields.retrive(field);
            return this;
        }

        // Where

        public QB_Join whereAre(QB_ConditionClause condition) {
            builder.conditions.add(condition);
            return this;
        }

        // Helper

        public String build() {
            return builder.build();
        }
    }

    public class QB implements QB_Part {
        private List<QB_Part> clauses = new QB_Part[10];

        public QB(sObjectType ofObject) {
            this(ofObject.getDescribe().getName());
        }

        public QB(String ofObject) {
            clauses.set(0, new QFields());
            clauses.set(2, new QFrom(ofObject));
        }

        public Query.QFields fields {
            get {
                return (Query.QFields) clauses[0];
            }
        }

        public Query.QSubQueries subQueries {
            get {
                if (clauses[1] == null) {
                    clauses.set(1, new Query.QSubQueries());
                }
                return (Query.QSubQueries) clauses[1];
            }
        }

        public Query.QScope scope {
            get {
                if (clauses[3] == null) {
                    clauses.set(3, new Query.QScope());
                }
                return (Query.QScope) clauses[3];
            }
        }

        public Query.QB_ConditionsGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new Query.QB_ConditionsGroup(true));
                }
                return (Query.QB_ConditionsGroup) clauses[4];
            }
        }

        public Query.QGroupBy groupBy {
            get {
                if (clauses[5] == null) {
                    clauses.set(5, new Query.QGroupBy());
                }
                return (Query.QGroupBy) clauses[5];
            }
        }

        public Query.QOrderBy orderBy {
            get {
                return orderBys.recentOrderBy();
            }
        }

        public Query.QOrderBys orderBys {
            get {
                if (clauses[6] == null) {
                    clauses.set(6, new Query.QOrderBys());
                }
                return (Query.QOrderBys) clauses[6];
            }
        }

        public Query.QLimit soqlLimit {
            get {
                if (clauses[7] == null) {
                    clauses.set(7, new Query.QLimit());
                }
                return (Query.QLimit) clauses[7];
            }
        }

        public Query.QOffset soqlOffset {
            get {
                if (clauses[8] == null) {
                    clauses.set(8, new Query.QOffset());
                }
                return (Query.QOffset) clauses[8];
            }
        }

        public Query.QFor soqlFor {
            get {
                if (clauses[9] == null) {
                    clauses.set(9, new Query.QFor());
                }
                return (Query.QFor) clauses[9];
            }
        }

        public String build() {
            List<String> soqlParts = new List<String>();

            for (QB_Part clause : clauses) {
                if (clause == null) {
                    continue;
                }
                soqlParts.add(clause.build());
            }

            return String.join(new List<String>(soqlParts), ' ');
        }
    }

    public class QFields implements QB_Part {
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

    public class QSubQueries implements QB_Part {
        private List<Query.QB_Sub> subQueries = new List<Query.QB_Sub>();

        public void add(Query.QB_Sub subQuery) {
            subQueries.add(subQuery);
        }

        public String build() {
            List<String> subQueriesSoql = new List<String>();

            for (Query.QB_Sub sub : subQueries) {
                subQueriesSoql.add('(' + sub.build() + ')');
            }

            return ', ' + String.join(subQueriesSoql, ', ');
        }
    }

    public class QFrom implements QB_Part {
        private String objectApiName;

        public QFrom(String objectType) {
            objectApiName = objectType;
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    public class QScope implements QB_Part {
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

    public class QGroupBy implements QB_Part {
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

    public class QOrderBys implements QB_Part {
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

    public class QOrderBy implements QB_Part {
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

    public class QLimit implements QB_Part {
        private Integer soqlLimit = 50000;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QOffset implements QB_Part {
        private Integer soqlOffset = 2000;

        public void fromRow(Integer soqlOffset) {
            this.soqlOffset = soqlOffset;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    public class QFor implements QB_Part {
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

    public class QB_Binder {
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

    public inherited sharing class QB_Executor {
        private Query.SharingLevel sharingMode = SharingLevel.INHERITED;
        private AccessLevel accessMode = AccessLevel.USER_MODE; // The object permissions, field-level security, and sharing rules of the current user are enforced.
        private AccessType accessType;

        private String query;
        private String queryIdentifier;
        private Boolean withPreview = false;
        private Boolean isCountQuery = false;
        private Map<String, Object> binding;

        private final Map<Query.SharingLevel, Query.DatabaseQuery> MODE_TO_EXECUTOR = new Map<Query.SharingLevel, Query.DatabaseQuery>{
            SharingLevel.WITH_SHARING => new Query.WithSharing(),
            SharingLevel.WITHOUT_SHARING => new Query.WithoutSharing(),
            SharingLevel.INHERITED => new Query.InheritedSharing()
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
