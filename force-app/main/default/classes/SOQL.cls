/**
 * Copyright (c) 2023 BeyondTheCloud.Dev
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
 * - ExcessivePublicCount: It is a library class and exposes all necessary methods to construct a query
 * - ExcessiveClassLength: It is a library and we tried to put everything into ONE class
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - PropertyNamingConventions: It was intentional to make the lib more fluent and readable
 * - FieldDeclarationsShouldBeAtStart: Developer who uses lib should see what's important at start
 * - ApexDoc: Variable names are self-documented.
 * - ExcessiveParameterList - Make methods similar to native SOQL
**/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.ExcessiveClassLength, PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.PropertyNamingConventions, PMD.FieldDeclarationsShouldBeAtStart, PMD.ApexDoc, PMD.ExcessiveParameterList')
public inherited sharing class SOQL implements Queryable {

    public static SubQuery SubQuery {
        get {
            return new QSubQuery(binder);
        }
    }

    public static FilterGroup FilterGroup { // A group to nest more filters
        get {
            return new QFilterGroup();
        }
    }

    public static Filter Filter {
        get {
            return new QFilter(binder);
        }
    }

    public static InnerJoin InnerJoin {
        get {
            return new QJoinQuery(binder);
        }
    }

    public interface Selector {
        Queryable query();
    }

    public interface Queryable {
        Queryable of(SObjectType ofObject);

        Queryable with(SObjectField field);
        Queryable with(SObjectField field1, SObjectField field2);
        Queryable with(SObjectField field1, SObjectField field2, SObjectField field3);
        Queryable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        Queryable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        Queryable with(List<SObjectField> fields); // For more than 5 fields
        Queryable with(String fields); // Dynamic SOQL
        Queryable with(String relationshipName, SObjectField field);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        Queryable with(String relationshipName, List<SObjectField> fields); // For more than 5 fields
        Queryable with(SubQuery subQuery); // SOQL.SubQuery

        Queryable count();
        Queryable count(SObjectField field);
        Queryable count(SObjectField field, String alias);

        Queryable delegatedScope();
        Queryable mineScope();
        Queryable mineAndMyGroupsScope();
        Queryable myTerritoryScope();
        Queryable myTeamTerritoryScope();
        Queryable teamScope();

        Queryable whereAre(FilterClause conditions); // SOQL.FilterGroup or SOQL.Filter
        Queryable whereAre(String conditions); // Conditions to evaluate

        Queryable groupBy(SObjectField field);
        Queryable groupByRollup(SObjectField field);

        Queryable orderBy(String field); // ASC, NULLS FIRST by default
        Queryable orderBy(String field, String direction); // dynamic order by, NULLS FIRST by default
        Queryable orderBy(SObjectField field); // ASC, NULLS FIRST by default
        Queryable orderBy(String relationshipName, SObjectField field); // ASC, NULLS FIRST by default
        Queryable sortDesc();
        Queryable nullsLast();

        Queryable setLimit(Integer amount);

        Queryable offset(Integer startingRow);

        Queryable forReference();
        Queryable forView();
        Queryable forUpdate();
        Queryable allRows();

        Queryable systemMode();

        Queryable withSharing(); // Works only with .systemMode()
        Queryable withoutSharing(); // Works only with .systemMode()

        Queryable mockId(String id);

        Queryable preview();

        Queryable stripInaccessible();
        Queryable stripInaccessible(AccessType accessType);

        Queryable byId(SObject record);
        Queryable byId(Id recordId);
        Queryable byIds(Set<Id> recordIds);
        Queryable byIds(List<Id> recordIds);
        Queryable byIds(List<SObject> records);

        String toString();
        Object toField(SObjectField fieldToExtract);
        Integer toInteger();
        SObject toObject();
        List<SObject> toList();
        List<AggregateResult> toAggregated();
        Map<Id, SObject> toMap();
        Database.QueryLocator toQueryLocator();
    }

    public interface SubQuery { // SOQL.SubQuery
        SubQuery of(String ofObject);

        SubQuery with(SObjectField field);
        SubQuery with(SObjectField field1, SObjectField field2);
        SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3);
        SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        SubQuery with(List<SObjectField> fields); // For more than 5 fields
        SubQuery with(String relationshipName, List<SObjectField> fields);

        SubQuery whereAre(FilterClause conditions); // SOQL.FilterGroup or SOQL.Filter

        SubQuery orderBy(SObjectField field);
        SubQuery orderBy(String relationshipName, SObjectField field);
        SubQuery sortDesc();
        SubQuery nullsLast();

        SubQuery setLimit(Integer amount);

        SubQuery offset(Integer startingRow);

        SubQuery forReference();
        SubQuery forView();
    }

    public abstract class FilterGroup implements FilterClause { // SOQL.FilterGroup
        public abstract FilterGroup add(FilterClause condition); // SOQL.Filter or SOQL.FilterGroup

        public abstract FilterGroup anyConditionMatching(); // All group filters will be join by OR

        public abstract FilterGroup conditionLogic(String order);
    }

    public abstract class Filter implements FilterClause { // SOQL.Filter
        public abstract Filter id();
        public abstract Filter recordType();
        public abstract Filter name();
        public abstract Filter with(SObjectField field);
        public abstract Filter with(String field);
        public abstract Filter with(String relationshipName, SObjectField field);

        public abstract Filter isNull(); // = NULL
        public abstract Filter isNotNull(); // != NULL
        public abstract Filter isTrue(); // = TRUE
        public abstract Filter isFalse(); // = FALSE
        public abstract Filter equal(Object value); // = :value
        public abstract Filter notEqual(Object value); // != :value
        public abstract Filter lessThan(Object value); // < :value
        public abstract Filter greaterThan(Object value); // > :value
        public abstract Filter lessThanOrEqual(Object value); // <= :value
        public abstract Filter greaterThanOrEqual(Object value); // >= :value
        public abstract Filter containsSome(List<String> values); // LIKE :values
        public abstract Filter contains(String value); // LIKE :'%' + value + '%'
        public abstract Filter endsWith(String value); // LIKE :'%' + value
        public abstract Filter startsWith(String value); // LIKE :value + '%'
        public abstract Filter isIn(Set<String> inSet); // IN :inSet
        public abstract Filter isIn(List<Object> inList); // IN :inList
        public abstract Filter isIn(InnerJoin joinQuery); // SOQL.InnerJoin
        public abstract Filter notIn(Set<String> inSet); // NOT IN :inSet
        public abstract Filter notIn(List<Object> inList); // NOT IN :inList
        public abstract Filter notIn(InnerJoin joinQuery); // SOQL.InnerJoin

        public abstract Filter removeWhenNull(); // Condition will be removed for value = null
    }

    public interface InnerJoin { // SOQL.InnerJoin
        InnerJoin of(SObjectType ofObject);

        InnerJoin with(SObjectField field);

        InnerJoin whereAre(FilterClause conditions); // SOQL.Filter or SOQL.FilterGroup
    }

    @TestVisible
    private static void setMock(String mockId, SObject record) {
        setMock(mockId, new List<SObject>{ record });
    }

    @TestVisible
    private static void setMock(String mockId, List<SObject> records) {
        mock.setMock(mockId, records);
    }

    @TestVisible
    private static void setCountMock(String mockId, Integer amount) {
        mock.setCountMock(mockId, amount);
    }

    @TestVisible
    private static void setMock(String mockId, String staticResource) {
        mock.setStaticResourceMock(mockId, staticResource);
    }

    // Config

    private static Mock mock = new Mock();

    private QueryBuilder builder;
    private static Binder binder;
    private Executor executor;

    public static SOQL of(sObjectType ofObject) {
        return new SOQL(ofObject);
    }

    private SOQL(SObjectType ofObject) {
        binder = new Binder();
        builder = new QueryBuilder(ofObject);
        executor = new Executor(ofObject);
    }

    public SOQL with(SObjectField field) {
        builder.fields.with(field);
        return this;
    }

    public SOQL with(SObjectField field1, SObjectField field2) {
        return with(field1).with(field2);
    }

    public SOQL with(SObjectField field1, SObjectField field2, SObjectField field3) {
        return with(field1).with(field2).with(field3);
    }

    public SOQL with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
        return with(field1).with(field2).with(field3).with(field4);
    }

    public SOQL with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
        return with(field1).with(field2).with(field3).with(field4).with(field5);
    }

    public SOQL with(List<SObjectField> fields) {
        builder.fields.with(fields);
        return this;
    }

    public SOQL with(String fields) {
        builder.fields.with(fields);
        return this;
    }

    public SOQL with(String relationshipName, SObjectField field) {
        return with(relationshipName, new List<SObjectField>{ field });
    }

    public SOQL with(String relationshipName, SObjectField field1, SObjectField field2) {
        return with(relationshipName, new List<SObjectField>{ field1, field2 });
    }

    public SOQL with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3) {
        return with(relationshipName, new List<SObjectField>{ field1, field2, field3 });
    }

    public SOQL with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
        return with(relationshipName, new List<SObjectField>{ field1, field2, field3, field4 });
    }

    public SOQL with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
        return with(relationshipName, new List<SObjectField>{ field1, field2, field3, field4, field5 });
    }

    public SOQL with(String relationshipName, List<SObjectField> fields) {
        builder.fields.with(relationshipName, fields);
        return this;
    }

    public SOQL with(SubQuery subQuery) {
        builder.subQueries.add(subQuery);
        return this;
    }

    public SOQL count() {
        builder.fields.count();
        return this;
    }

    public SOQL count(SObjectField field) {
        builder.fields.count(field);
        return this;
    }

    public SOQL count(SObjectField field, String alias) {
        builder.fields.count(field, alias);
        return this;
    }

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

    public SOQL whereAre(FilterClause conditions) {
        builder.conditions.add(conditions);
        return this;
    }

    public SOQL whereAre(String conditions) {
        builder.conditions.evaluate(conditions);
        return this;
    }

    public SOQL groupBy(SObjectField field) {
        builder.groupBy.with(field);
        return this;
    }

    public SOQL groupByRollup(SObjectField field) {
        builder.groupBy.rollup(field);
        return this;
    }

    public SOQL orderBy(String field) { // Order By - ASC, NULLS FIRST by default
        builder.orderBys.newOrderBy().with(field);
        return this;
    }

    public SOQL orderBy(String field, String direction) { // NULLS FIRST by default
        builder.orderBys.newOrderBy().with(field).sortingOrder(direction);
        return this;
    }

    public SOQL orderBy(SObjectField field) { // Order By - ASC, NULLS FIRST by default
        builder.orderBys.newOrderBy().with(field);
        return this;
    }

    public SOQL orderBy(String relationshipName, SObjectField field) {
        builder.orderBys.newOrderBy().with(relationshipName, field);
        return this;
    }

    public SOQL sortDesc() {
        builder.latestOrderBy.sortDesc();
        return this;
    }

    public SOQL nullsLast() {
        builder.latestOrderBy.nullsLast();
        return this;
    }

    public SOQL setLimit(Integer amount) {
        builder.soqlLimit.max(amount);
        return this;
    }

    public SOQL offset(Integer startingRow) {
        builder.soqlOffset.offset(startingRow);
        return this;
    }

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

    public SOQL systemMode() { // User Mode by default
        executor.systemMode();
        return this;
    }

    public SOQL stripInaccessible() {
        return stripInaccessible(AccessType.READABLE);
    }

    public SOQL stripInaccessible(AccessType accessType) {
        executor.stripInaccessible(accessType);
        return this;
    }

    public SOQL withSharing() {
        executor.withSharing();
        return this;
    }

    public SOQL withoutSharing() {
        executor.withoutSharing();
        return this;
    }

    public SOQL mockId(String id) {
        executor.mockId(id);
        return this;
    }

    public SOQL preview() {
        System.debug(LoggingLevel.ERROR, '\n\n============ SOQL Preview ============\n' + toString() + '\n=======================================\n');
        System.debug(LoggingLevel.ERROR, '\n\n============ SOQL Binding ============\n' + JSON.serializePretty(binding()) + '\n=======================================\n');
        return this;
    }

    public Map<String, Object> binding() {
        return binder.getBindingMap();
    }

    public override String toString() {
        return builder.toString();
    }

    public Object toField(SObjectField fieldToExtract) {
        return with(fieldToExtract).toObject().get(fieldToExtract);
    }

    public Integer toInteger() {
        return executor.toInteger(builder.toString(), binder.getBindingMap());
    }

    public SObject toObject() {
        return executor.toObject(builder.toString(), binder.getBindingMap());
    }

    public List<SObject> toList() {
        return executor.toList(builder.toString(), binder.getBindingMap());
    }

    public List<AggregateResult> toAggregated() {
        return (List<AggregateResult>) toList();
    }

    public Map<Id, SObject> toMap() {
        return new Map<Id, SObject>(toList());
    }

    public Database.QueryLocator toQueryLocator() {
        return executor.toQueryLocator(builder.toString(), binder.getBindingMap());
    }

    public SOQL byId(SObject record) {
        return byId(record.Id);
    }

    public SOQL byId(Id recordId) {
        return whereAre(Filter.id().equal(recordId));
    }

    public SOQL byIds(Set<Id> recordIds) {
        return byIds(new List<Id>(recordIds));
    }

    public SOQL byIds(List<Id> recordIds) {
        return whereAre(Filter.id().isIn(recordIds));
    }

    public SOQL byIds(List<SObject> records) {
        return whereAre(Filter.id().isIn(records));
    }

    public interface QueryClause {
        String toString();
    }

    private class QueryBuilder implements QueryClause {
        private List<QueryClause> clauses = new QueryClause[10];

        public QueryBuilder(SObjectType ofObject) {
            this(ofObject.getDescribe().getName());
        }

        public QueryBuilder(String ofObject) {
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

        public MainFilterGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new MainFilterGroup());
                }
                return (MainFilterGroup) clauses[4];
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

        public QOrderBy latestOrderBy {
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

        public override String toString() {
            List<String> soqlParts = new List<String>();

            for (QueryClause clause : clauses) {
                if (clause == null) {
                    continue;
                }
                soqlParts.add(clause.toString());
            }

            return String.join(soqlParts, ' ').trim();
        }
    }

    private class QFields implements QueryClause {
        private Set<String> queryFields = new Set<String>();
        private Set<String> queryCounts = new Set<String>();

        public void count() {
            // COUNT() must be the only element in the SELECT list.
            count('COUNT()');
        }

        public void count(SObjectField field) {
            count('COUNT(' + field + ')');
        }

        public void count(SObjectField field, String alias) {
            count('COUNT(' + field + ') ' + alias);
        }

        public void count(String countSoql) {
            // clear all default fields to avoid "Field must be grouped or aggregated"
            queryFields.clear();
            queryCounts.add(countSoql);
        }

        public void with(String fields) {
            queryFields.addAll(fields.deleteWhitespace().split(','));
        }

        public void with(List<SObjectField> fields) {
            for (SObjectField field : fields) {
                with(field);
            }
        }

        public void with(SObjectField field) {
            queryFields.add(field.getDescribe().getName());
        }

        public void with(String relationshipPath, List<SObjectField> fields) {
            for (SObjectField field : fields) {
                with(relationshipPath, field);
            }
        }

        public void with(String relationshipPath, SObjectField field) {
            queryFields.add(relationshipPath + '.' + field);
        }

        public override String toString() {
            if (queryFields.isEmpty() && queryCounts.isEmpty()) {
                return 'SELECT Id';
            }

            List<String> selectStatement = new List<String>();

            selectStatement.addAll(queryCounts);
            selectStatement.addAll(queryFields);

            return 'SELECT ' + String.join(selectStatement, ', ');
        }
    }

    private class QSubQuery implements SubQuery {
        private QueryBuilder builder;
        private Binder binder;

        public QSubQuery(Binder binder) {
            this.binder = binder;
        }

        public QSubQuery of(String ofObject) {
            builder = new QueryBuilder(ofObject);
            return this;
        }

        public QSubQuery with(SObjectField field) {
            builder.fields.with(field);
            return this;
        }

        public QSubQuery with(SObjectField field1, SObjectField field2) {
            return with(field1).with(field2);
        }

        public QSubQuery with(SObjectField field1, SObjectField field2, SObjectField field3) {
            return with(field1).with(field2).with(field3);
        }

        public QSubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
            return with(field1).with(field2).with(field3).with(field4);
        }

        public QSubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
            return with(field1).with(field2).with(field3).with(field4).with(field5);
        }

        public QSubQuery with(List<SObjectField> fields) {
            builder.fields.with(fields);
            return this;
        }

        public QSubQuery with(String relationshipName, List<SObjectField> fields) {
            builder.fields.with(relationshipName, fields);
            return this;
        }

        public QSubQuery whereAre(FilterClause conditions) {
            builder.conditions.add(conditions);
            return this;
        }

        public QSubQuery orderBy(SObjectField field) {
            builder.orderBys.newOrderBy().with(field);
            return this;
        }

        public QSubQuery orderBy(String relationshipName, SObjectField field) {
            builder.orderBys.newOrderBy().with(relationshipName, field);
            return this;
        }

        public QSubQuery sortDesc() {
            builder.latestOrderBy.sortDesc();
            return this;
        }

        public QSubQuery nullsLast() {
            builder.latestOrderBy.nullsLast();
            return this;
        }

        public QSubQuery setLimit(Integer amount) {
            builder.soqlLimit.max(amount);
            return this;
        }

        public QSubQuery offset(Integer startingRow) {
            builder.soqlOffset.offset(startingRow);
            return this;
        }

        public QSubQuery forReference() {
            builder.soqlFor.forReference();
            return this;
        }

        public QSubQuery forView() {
            builder.soqlFor.forView();
            return this;
        }

        public override String toString() {
            return builder.toString();
        }
    }

    private class QSubQueries implements QueryClause {
        private List<SubQuery> subQueries = new List<SubQuery>();

        public void add(SubQuery subQuery) {
            subQueries.add(subQuery);
        }

        public override String toString() {
            List<String> subQueriesStrings = new List<String>();

            for (SubQuery sub : subQueries) {
                subQueriesStrings.add('(' + sub + ')');
            }

            return ', ' + String.join(subQueriesStrings, ', ');
        }
    }

    private class QFrom implements QueryClause {
        private String objectApiName;

        public QFrom(String objectType) {
            objectApiName = objectType;
        }

        public override String toString() {
            return 'FROM ' + objectApiName;
        }
    }

    private class QScope implements QueryClause {
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

        public override String toString() {
            return 'USING SCOPE ' + scope;
        }
    }

    public interface FilterClause {
        Boolean isEmpty();
    }

    private virtual class QFilterGroup extends FilterGroup {
        private List<FilterClause> queryConditions = new List<FilterClause>();
        private String order;
        private String connector = 'AND';

        public override FilterGroup add(FilterClause condition) {
            if (condition.isEmpty()) {
                return this;
            }
            queryConditions.add(condition);
            return this;
        }

        public override FilterGroup anyConditionMatching() {
            connector = 'OR';
            return this;
        }

        public override FilterGroup conditionLogic(String order) {
            this.order = order;
            return this;
        }

        public Boolean isEmpty() {
            return queryConditions.isEmpty();
        }

        public virtual override String toString() {
            return '(' + buildNested() + ')';
        }

        private void setDefaultOrderWhenEmpty() {
            if (String.isNotEmpty(order)) {
                return;
            }

            List<String> defaultOrder = new List<String>();

            for (Integer i = 1; i <= queryConditions.size(); i++) {
                defaultOrder.add(String.valueOf(i));
            }

            order = String.join(defaultOrder, ' ' + connector + ' '); // e.g (1 AND 2 AND 3)
        }

        public String buildNested() {
            setDefaultOrderWhenEmpty();

            String conditions = applySpecialCharactersToOrder(); // e.g (*1* AND (*2* OR *3*))

            for (Integer i = 0; i < queryConditions.size(); i++) {
                conditions = conditions.replace(
                    conditionNumberWithSpecialCharacters(i + 1), // e.g *1*
                    queryConditions.get(i).toString()
                );
            }

            return conditions;
        }

        private String applySpecialCharactersToOrder() {
            for (Integer i = 1; i <= queryConditions.size(); i++) {
                order = order.replace(String.valueOf(i), conditionNumberWithSpecialCharacters(i));
            }

            return order; // e.g (*1* AND (*2* OR *3*))
        }

        private String conditionNumberWithSpecialCharacters(Integer conditionNumber) {
            return '*' + conditionNumber + '*';
        }
    }

    private class MainFilterGroup extends QFilterGroup implements QueryClause {
        private String stringConditions;

        public void evaluate(String conditions) {
            stringConditions = String.escapeSingleQuotes(conditions);
        }

        public override String toString() {
            if (String.isNotEmpty(stringConditions)) {
                return 'WHERE ' + stringConditions;
            }

            if (isEmpty()) {
                return '';
            }

            return 'WHERE ' + buildNested();
        }
    }

    private class QFilter extends Filter {
        private String field;
        private String comperator;
        private Object value;

        private Binder binder;

        public QFilter(Binder binder) {
            this.binder = binder;
        }

        public override Filter id() {
            return with('Id');
        }

        public override Filter recordType() {
            return with('RecordType.DeveloperName');
        }

        public override Filter name() {
            return with('Name');
        }

        public override Filter with(SObjectField field) {
            return with(field.getDescribe().getName());
        }

        public override Filter with(String relationshipName, SObjectField field) {
            return with(relationshipName + '.' + field);
        }

        public override Filter with(String field) {
            this.field = field;
            return this;
        }

        public override Filter isNull() {
            return equal(null);
        }

        public override Filter isNotNull() {
            return notEqual(null);
        }

        public override Filter isTrue() {
            return equal(true);
        }

        public override Filter isFalse() {
            return equal(false);
        }

        public override Filter equal(Object value) {
            return set('=', value);
        }

        public override Filter notEqual(Object value) {
            return set('!=', value);
        }

        public override Filter lessThan(Object value) {
            return set('<', value);
        }

        public override Filter greaterThan(Object value) {
            return set('>', value);
        }

        public override Filter lessThanOrEqual(Object value) {
            return set('<=', value);
        }

        public override Filter greaterThanOrEqual(Object value) {
            return set('>=', value);
        }

        public override Filter containsSome(List<String> values) {
            return set('LIKE', values);
        }

        public override Filter contains(String value) {
            return set('LIKE', '%' + formattedString(value) + '%');
        }

        public override Filter endsWith(String value) {
            return set('LIKE', '%' + formattedString(value));
        }

        public override Filter startsWith(String value) {
            return set('LIKE', formattedString(value) + '%');
        }

        private String formattedString(String value) {
            return value == null ? value : String.escapeSingleQuotes(value.trim());
        }

        // The Set collection type does not allow to implicitly cast Set<Object>
        public override Filter isIn(Set<String> inSet) {
            return set('IN', inSet);
        }

        public override Filter isIn(List<Object> inList) {
            return set('IN', inList);
        }

        // The Set collection type does not allow to implicitly cast Set<Object>
        public override Filter notIn(Set<String> inSet) {
            return set('NOT IN', inSet);
        }

        public override Filter notIn(List<Object> inList) {
            return set('NOT IN', inList);
        }

        public override Filter isIn(InnerJoin joinQuery) {
            return set('IN', joinQuery);
        }

        public override Filter notIn(InnerJoin joinQuery) {
            return set('NOT IN', joinQuery);
        }

        private Filter set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public Boolean isEmpty() {
            return String.isEmpty(field);
        }

        public override Filter removeWhenNull() {
            if (value == null || isLikeNull()) {
                // Set field as empty to meet isEmpty and ignore condition
                with('');
            }
            return this;
        }

        private Boolean isLikeNull() {
            return value == 'null%' || value == '%null' || value == '%null%';
        }

        public override String toString() {
            if (value instanceOf InnerJoin) {
                return field + ' ' + comperator + ' (' + ((InnerJoin) value).toString() + ')';
            }

            return field + ' ' + comperator + ' :' + binder.bind(value);
        }
    }

    private class QJoinQuery implements InnerJoin {
        private QueryBuilder builder;
        private Binder binder;

        public QJoinQuery(Binder binder) {
            this.binder = binder;
        }

        public QJoinQuery of(SObjectType ofObject) {
            builder = new QueryBuilder(ofObject);
            return this;
        }

        public QJoinQuery with(SObjectField field) {
            builder.fields.with(field);
            return this;
        }

        public QJoinQuery whereAre(FilterClause condition) {
            builder.conditions.add(condition);
            return this;
        }

        public override String toString() {
            return builder.toString();
        }
    }

    private class QGroupBy implements QueryClause {
        private Set<String> groupByFields = new Set<String>();

        public void with(SObjectField field) {
            groupByFields.add(field.getDescribe().getName());
        }

        public void rollup(SObjectField field) {
            groupByFields.add('ROLLUP(' + field + ')');
        }

        public override String toString() {
            return 'GROUP BY ' + String.join(new List<String>(groupByFields), ', ');
        }
    }

    private class QOrderBys implements QueryClause {
        public List<QOrderBy> orderBys = new List<QOrderBy>();

        public QOrderBy newOrderBy() {
            orderBys.add(new QOrderBy());
            return recentOrderBy();
        }

        public QOrderBy recentOrderBy() {
            return orderBys.get(orderBys.size() - 1);
        }

        public override String toString() {
            List<String> orderFields = new List<String>();

            for (QOrderBy orderBy : orderBys) {
                orderFields.add(orderBy.toString());
            }

            return 'ORDER BY ' + String.join(orderFields, ', ');
        }
    }

    private class QOrderBy implements QueryClause {
        private String orderField;
        private String sortingOrder = 'ASC';
        private String nullsOrder = 'FIRST';

        public QOrderBy with(SObjectField field) {
            return with(field.getDescribe().getName());
        }

        public QOrderBy with(String relationshipName, SObjectField field) {
            return with(relationshipName + '.' + field);
        }

        public QOrderBy with(String field) {
            orderField = field;
            return this;
        }

        public void sortDesc() {
            sortingOrder('DESC');
        }

        public QOrderBy sortingOrder(String direction) {
            sortingOrder = direction;
            return this;
        }

        public void nullsLast() {
            nullsOrder = 'LAST';
        }

        public override String toString() {
            return orderField + ' ' + sortingOrder + ' NULLS ' + nullsOrder;
        }
    }

    private class QLimit implements QueryClause {
        private Integer soqlLimit;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public override String toString() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    private class QOffset implements QueryClause {
        private Integer soqlOffset;

        public void offset(Integer fromRow) {
            soqlOffset = fromRow;
        }

        public override String toString() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    private class QFor implements QueryClause {
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

        public override String toString() {
            return forStatement;
        }
    }

    private class Binder {
        private Integer bindIndex = 0;
        private Map<String, Object> binding = new Map<String, Object>();

        public String bind(Object value) {
            bindIndex++;
            binding.put('v' + bindIndex, value);

            return 'v' + bindIndex;
        }

        public Map<String, Object> getBindingMap() {
            return binding;
        }
    }

    private class Mock {
        private final Map<String, List<SObject>> mocks = new Map<String, List<SObject>>();
        private final Map<String, String> staticResourceMocks = new Map<String, String>();
        private final Map<String, Integer> countMocks = new Map<String, Integer>();

        public void setMock(String mockId, List<SObject> records) {
            mocks.put(mockId, records);
        }

        public void setCountMock(String mockId, Integer amount) {
            countMocks.put(mockId, amount);
        }

        public void setStaticResourceMock(String mockId, String staticResourceName) {
            staticResourceMocks.put(mockId, staticResourceName);
        }

        public Boolean hasMock(String mockId) {
            return mocks.containsKey(mockId);
        }

        public Boolean hasStaticResourceMock(String mockId) {
            return staticResourceMocks.containsKey(mockId);
        }

        public List<SObject> getMocks(String mockId) {
            return mocks.get(mockId);
        }

        public List<SObject> getStaticResourceMocks(String mockId, SObjectType sObjectType) {
            return Test.loadData(sObjectType, staticResourceMocks.get(mockId));
        }

        public Boolean hasCountMock(String mockId) {
            return countMocks.containsKey(mockId);
        }

        public Integer getCountMock(String mockId) {
            return countMocks.get(mockId);
        }
    }

    private inherited sharing class Executor {
        private AccessLevel accessMode = AccessLevel.USER_MODE; // The object permissions, field-level security, sharing rules are enforced.
        private DatabaseQuery sharingExecutor = new InheritedSharing();
        private SObjectType ofObject;
        private AccessType accessType;
        private String mockId;

        public Executor(SObjectType ofObject) {
            this.ofObject = ofObject;
        }

        public void withSharing() {
            sharingExecutor = new WithSharing();
        }

        public void withoutSharing() {
            sharingExecutor = new WithoutSharing();
        }

        public void stripInaccessible(AccessType type) {
            accessType = type;
        }

        public void systemMode() { // The object permissions, field-level permissions are ignored, sharing rules are controlled by the sharingMode.
            accessMode = AccessLevel.SYSTEM_MODE;
        }

        public void mockId(String id) {
            mockId = id;
        }

        public SObject toObject(String query, Map<String, Object> binding) {
            try {
                return toList(query, binding)[0];
            } catch (ListException e) {
                return null; // List index out of bounds: 0
            }
        }

        public Integer toInteger(String query, Map<String, Object> binding) {
            if (mock.hasCountMock(mockId)) {
                return mock.getCountMock(mockId);
            }

            return sharingExecutor.executeCount(query, binding, accessMode);
        }

        public List<SObject> toList(String query, Map<String, Object> binding) {
            if (mock.hasMock(mockId)) {
                return mock.getMocks(mockId);
            }

            if (mock.hasStaticResourceMock(mockId)) {
                return mock.getStaticResourceMocks(mockId, ofObject);
            }

            if (accessType == null) {
                return sharingExecutor.execute(query, binding, accessMode);
            }

            return Security.stripInaccessible(
                accessType,
                sharingExecutor.execute(query, binding, accessMode)
            ).getRecords();
        }

        public Database.QueryLocator toQueryLocator(String query, Map<String, Object> binding) {
            return Database.getQueryLocatorWithBinds(query, binding, accessMode);
        }
    }

    private interface DatabaseQuery {
        List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel);
        Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel);
    }

    private inherited sharing class InheritedSharing implements DatabaseQuery {
        public List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private without sharing class WithoutSharing implements DatabaseQuery {
        public List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private with sharing class WithSharing implements DatabaseQuery {
        public List<SObject> execute(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer executeCount(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }
}
