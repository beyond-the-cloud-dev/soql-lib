public inherited sharing class SOQL implements Querable {

    public static SOQL.QB_Sub Sub {
        get {
            return new SOQL.QB_Sub(binder);
        }
    }

    public static SOQL.QB_ConditionsGroup ConditionsGroup {
        get {
            return new SOQL.QB_ConditionsGroup(false);
        }
    }

    public static SOQL.QB_Condition Condition {
        get {
            return new SOQL.QB_Condition(binder);
        }
    }

    public static SOQL.QB_Join InnerJoin {
        get {
            return new SOQL.QB_Join(binder);
        }
    }

    public interface Querable {
        SOQL of(sObjectType ofObject);

        SOQL field(sObjectField field);
        SOQL fields(List<sObjectField> fields);
        SOQL fields(String commaSeparatedFields);
        SOQL relatedFields(String relationshipPath, List<sObjectField> fields);
        SOQL count();
        SOQL countAs(sObjectField field, String alias);

        SOQL subQuery(QB_Sub subQuery); //SOQL.Sub

        SOQL delegatedScope();
        SOQL mineScope();
        SOQL mineAndMyGroupsScope();
        SOQL myTerritoryScope();
        SOQL myTeamTerritoryScope();
        SOQL teamScope();

        SOQL whereAre(QB_ConditionClause conditions); //SOQL.ConditionsGroup or SOQL.Condition

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

    public interface SoqlSubQuery {
        SOQL.QB_Sub of(String ofObject);

        SOQL.QB_Sub fields(List<sObjectField> fields);
        SOQL.QB_Sub relatedFields(String relationshipPath, List<sObjectField> fields);

        SOQL.QB_Sub whereAre(QB_ConditionClause conditions); //SOQL.ConditionsGroup or SOQL.Condition

        SOQL.QB_Sub orderBy(sObjectField field);
        SOQL.QB_Sub orderByRelated(String path, sObjectField field);
        SOQL.QB_Sub sortDesc();
        SOQL.QB_Sub nullsLast();

        SOQL.QB_Sub setLimit(Integer amount);

        SOQL.QB_Sub offset(Integer startingRow);

        SOQL.QB_Sub forReference();
        SOQL.QB_Sub forView();
    }

    public interface SoqlCondition {
        SOQL.QB_Condition id();
        SOQL.QB_Condition recordTypeDeveloperName();
        SOQL.QB_Condition field(SObjectField field);
        SOQL.QB_Condition field(String field);
        SOQL.QB_Condition relatedField(String relationshipPath, SObjectField field);

        SOQL.QB_Condition isNull();
        SOQL.QB_Condition isNotNull();
        SOQL.QB_Condition equal(Object value);
        SOQL.QB_Condition notEqual(Object value);
        SOQL.QB_Condition lessThan(Object value);
        SOQL.QB_Condition greaterThan(Object value);
        SOQL.QB_Condition lessThanOrEqual(Object value);
        SOQL.QB_Condition greaterThanOrEqual(Object value);
        SOQL.QB_Condition likeAnyBoth(String value);
        SOQL.QB_Condition likeAnyLeft(String value);
        SOQL.QB_Condition likeAnyRight(String value);
        SOQL.QB_Condition isIn(List<Object> inList);
        SOQL.QB_Condition isNotIn(List<Object> inList);
        SOQL.QB_Condition isIn(SOQL.QB_Join joinQuery); //SOQL.JoinQuery
        SOQL.QB_Condition isNotIn(SOQL.QB_Join joinQuery); //SOQL.JoinQuery
    }

    public interface SoqlConditionsGroup {
        SOQL.QB_ConditionsGroup add(QB_ConditionClause condition); //SOQL.Condition or SOQL.QB_ConditionsGroup
        SOQL.QB_ConditionsGroup order(String order);
    }

    private static QB_Binder binder;

    private QB builder;
    private QB_Executor executor;

    public static SOQL of(sObjectType ofObject) {
        return new SOQL(ofObject);
    }

    private SOQL(sObjectType ofObject) {
        binder = new QB_Binder();
        builder = new QB(ofObject);
        executor = new QB_Executor();
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

    public SOQL subQuery(SOQL.QB_Sub subQuery) {
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

    public SOQL whereAre(QB_ConditionClause conditions) {
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
        builder.soqlOffset.fromRow(startingRow);
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
        return whereAre(SOQL.Condition.id().equal(recordId));
    }

    public SOQL getByIds(List<Id> recordIds) {
        return whereAre(SOQL.Condition.id().isIn(recordIds));
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

    public class QB_Condition implements SOQL.QB_ConditionClause, SOQL.SoqlCondition {
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

        public QB_Condition isIn(SOQL.QB_Join joinQuery) {
            return set('IN', joinQuery);
        }

        public QB_Condition isNotIn(SOQL.QB_Join joinQuery) {
            return set('NOT IN', joinQuery);
        }

        private QB_Condition set(String comperator, SOQL.QB_Join joinQuery) {
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

    public class QB_ConditionsGroup implements SOQL.QB_ConditionClause, SOQL.QB_Part, SOQL.SoqlConditionsGroup {
        private List<SOQL.QB_ConditionClause> queryConditions = new List<QB_ConditionClause>();
        private String order = '';
        private Boolean isParent = false;

        public QB_ConditionsGroup(Boolean isParent) {
            this.isParent = isParent;
        }

        public SOQL.QB_ConditionsGroup add(QB_ConditionClause condition) {
            queryConditions.add(condition);
            return this;
        }

        public SOQL.QB_ConditionsGroup order(String order) {
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

    public class QB_Join implements QB_Part {
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

        public SOQL.QFields fields {
            get {
                return (SOQL.QFields) clauses[0];
            }
        }

        public SOQL.QSubQueries subQueries {
            get {
                if (clauses[1] == null) {
                    clauses.set(1, new SOQL.QSubQueries());
                }
                return (SOQL.QSubQueries) clauses[1];
            }
        }

        public SOQL.QScope scope {
            get {
                if (clauses[3] == null) {
                    clauses.set(3, new SOQL.QScope());
                }
                return (SOQL.QScope) clauses[3];
            }
        }

        public SOQL.QB_ConditionsGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new SOQL.QB_ConditionsGroup(true));
                }
                return (SOQL.QB_ConditionsGroup) clauses[4];
            }
        }

        public SOQL.QGroupBy groupBy {
            get {
                if (clauses[5] == null) {
                    clauses.set(5, new SOQL.QGroupBy());
                }
                return (SOQL.QGroupBy) clauses[5];
            }
        }

        public SOQL.QOrderBy orderBy {
            get {
                return orderBys.recentOrderBy();
            }
        }

        public SOQL.QOrderBys orderBys {
            get {
                if (clauses[6] == null) {
                    clauses.set(6, new SOQL.QOrderBys());
                }
                return (SOQL.QOrderBys) clauses[6];
            }
        }

        public SOQL.QLimit soqlLimit {
            get {
                if (clauses[7] == null) {
                    clauses.set(7, new SOQL.QLimit());
                }
                return (SOQL.QLimit) clauses[7];
            }
        }

        public SOQL.QOffset soqlOffset {
            get {
                if (clauses[8] == null) {
                    clauses.set(8, new SOQL.QOffset());
                }
                return (SOQL.QOffset) clauses[8];
            }
        }

        public SOQL.QFor soqlFor {
            get {
                if (clauses[9] == null) {
                    clauses.set(9, new SOQL.QFor());
                }
                return (SOQL.QFor) clauses[9];
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
        private List<SOQL.QB_Sub> subQueries = new List<SOQL.QB_Sub>();

        public void add(SOQL.QB_Sub subQuery) {
            subQueries.add(subQuery);
        }

        public String build() {
            List<String> subQueriesSoql = new List<String>();

            for (SOQL.QB_Sub sub : subQueries) {
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

            if (SOQL_Mock.containsCountMock(queryIdentifier)) {
                return SOQL_Mock.getCountMock(queryIdentifier);
            }

            return MODE_TO_EXECUTOR.get(sharingMode).executeCount(query, binding, accessMode);
        }

        public List<sObject> asList() {
            if (withPreview) {
                previewSoql();
                previewBinding();
            }

            if (SOQL_Mock.containsMock(queryIdentifier)) {
                return SOQL_Mock.getMock(queryIdentifier);
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
