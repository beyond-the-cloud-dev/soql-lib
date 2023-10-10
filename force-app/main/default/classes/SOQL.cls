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
public virtual inherited sharing class SOQL implements Queryable {

    public static SubQuery SubQuery {
        get {
            return new QSubQuery();
        }
    }

    public static FilterGroup FilterGroup {
        get {
            return new QFilterGroup();
        }
    }

    public static Filter Filter {
        get {
            return new QFilter();
        }
    }

    public static InnerJoin InnerJoin {
        get {
            return new QJoinQuery();
        }
    }

    public interface Selector {
        Queryable query();
    }

    public interface Queryable {
        // SELECT
        Queryable with(SObjectField field);
        Queryable with(SObjectField field1, SObjectField field2);
        Queryable with(SObjectField field1, SObjectField field2, SObjectField field3);
        Queryable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        Queryable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        Queryable with(List<SObjectField> fields);
        Queryable with(Iterable<String> fields);
        Queryable with(String fields);
        Queryable with(SObjectField field, String alias);
        Queryable with(String relationshipName, SObjectField field);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        Queryable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        Queryable with(String relationshipName, List<SObjectField> fields);
        Queryable with(SubQuery subQuery);
        // COUNT
        Queryable count();
        Queryable count(SObjectField field);
        Queryable count(SObjectField field, String alias);
        // GROUPING
        Queryable grouping(SObjectField field, String alias);
        // USING SCOPE
        Queryable delegatedScope();
        Queryable mineScope();
        Queryable mineAndMyGroupsScope();
        Queryable myTerritoryScope();
        Queryable myTeamTerritoryScope();
        Queryable teamScope();
        // WHERE
        Queryable whereAre(FilterGroup filterGroup);
        Queryable whereAre(Filter filter);
        Queryable whereAre(String conditions);
        Queryable conditionLogic(String order);
        Queryable anyConditionMatching();
        // GROUP BY
        Queryable groupBy(SObjectField field);
        Queryable groupByRollup(SObjectField field);
        Queryable groupByCube(SObjectField field);
        // ORDER BY
        Queryable orderBy(String field);
        Queryable orderBy(String field, String direction);
        Queryable orderBy(SObjectField field);
        Queryable orderBy(String relationshipName, SObjectField field);
        Queryable sortDesc();
        Queryable nullsLast();
        // LIMIT
        Queryable setLimit(Integer amount);
        // OFFSET
        Queryable offset(Integer startingRow);
        // FOR
        Queryable forReference();
        Queryable forView();
        Queryable forUpdate();
        Queryable allRows();
        // FIELD-LEVEL SECURITY
        Queryable systemMode();
        Queryable stripInaccessible();
        Queryable stripInaccessible(AccessType accessType);
        // SHARING MODE
        Queryable withSharing();
        Queryable withoutSharing();
        // MOCKING
        Queryable mockId(String id);
        // DEBUGGING
        Queryable preview();
        // PREDEFINIED
        Queryable byId(SObject record);
        Queryable byId(Id recordId);
        Queryable byIds(Iterable<Id> recordIds);
        Queryable byIds(List<SObject> records);
        // RESULT
        Boolean doExist();
        String toString();
        Object toValueOf(SObjectField fieldToExtract);
        Set<String> toValuesOf(SObjectField fieldToExtract);
        Integer toInteger();
        SObject toObject();
        List<SObject> toList();
        List<AggregateResult> toAggregated();
        Map<Id, SObject> toMap();
        Map<String, SObject> toMap(SObjectField keyField);
        Map<String, String> toMap(SObjectField keyField, SObjectField valueField);
        Map<String, List<SObject>> toAggregatedMap(SObjectField keyField);
        Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField);
        Database.QueryLocator toQueryLocator();
    }

    public interface SubQuery {
        SubQuery of(String ofObject);
        // SELECT
        SubQuery with(SObjectField field);
        SubQuery with(SObjectField field1, SObjectField field2);
        SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3);
        SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        SubQuery with(List<SObjectField> fields);
        SubQuery with(String relationshipName, List<SObjectField> fields);
        SubQuery with(SubQuery subQuery);
        // WHERE
        SubQuery whereAre(FilterGroup filterGroup);
        SubQuery whereAre(Filter filter);
        //ORDER BY
        SubQuery orderBy(SObjectField field);
        SubQuery orderBy(String relationshipName, SObjectField field);
        SubQuery sortDesc();
        SubQuery nullsLast();
        // LIMIT
        SubQuery setLimit(Integer amount);
        // OFFSET
        SubQuery offset(Integer startingRow);
        // FOR
        SubQuery forReference();
        SubQuery forView();
    }

    public interface FilterGroup {
        // ADD CONDITION
        FilterGroup add(FilterGroup filterGroup);
        FilterGroup add(Filter filter);
        FilterGroup add(String dynamicCondition);
        // ORDER
        FilterGroup anyConditionMatching();
        FilterGroup conditionLogic(String order);

        Boolean hasValues();
    }

    public interface Filter {
        // FIELDS
        Filter id();
        Filter recordType();
        Filter name();
        Filter with(SObjectField field);
        Filter with(String field);
        Filter with(String relationshipName, SObjectField field);
        // COMPERATORS
        Filter isNull();
        Filter isNotNull();
        Filter isTrue();
        Filter isFalse();
        Filter equal(Object value);
        Filter notEqual(Object value);
        Filter lessThan(Object value);
        Filter greaterThan(Object value);
        Filter lessOrEqual(Object value);
        Filter greaterOrEqual(Object value);
        Filter containsSome(List<String> values);
        Filter contains(String value);
        Filter notContains(String value);
        Filter endsWith(String value);
        Filter notEndsWith(String value);
        Filter startsWith(String value);
        Filter notStartsWith(String value);
        Filter contains(String prefix, String value, String suffix);
        Filter notContains(String prefix, String value, String suffix);
        Filter isIn(Iterable<Object> iterable);
        Filter isIn(List<Object> inList);
        Filter isIn(InnerJoin joinQuery);
        Filter notIn(Iterable<Object> iterable);
        Filter notIn(List<Object> inList);
        Filter notIn(InnerJoin joinQuery);
        Filter includesAll(Iterable<String> values);
        Filter includesSome(Iterable<String> values);
        Filter excludesAll(Iterable<String> values);
        Filter excludesSome(Iterable<String> values);
        // ADDITIONAL
        Filter asDateLiteral();
        Filter ignoreWhen(Boolean logicExpression);

        Boolean hasValue();
    }

    public interface InnerJoin {
        InnerJoin of(SObjectType ofObject);
        // SELECT
        InnerJoin with(SObjectField field);
        // WHERE
        InnerJoin whereAre(FilterGroup filterGroup);
        InnerJoin whereAre(Filter filter);
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

    // Config

    private static Mock mock = new Mock();
    private static Binder binder;

    private QueryBuilder builder;
    private Executor executor;

    public static SOQL of(SObjectType ofObject) {
        return new SOQL(ofObject);
    }

    public static SOQL of(String ofObject) {
        return new SOQL(ofObject);
    }

    public SOQL(SObjectType ofObject) {
        this(ofObject.getDescribe().getName());
    }

    public SOQL(String ofObject) {
        binder = new Binder();
        builder = new QueryBuilder(ofObject);
        executor = new Executor(ofObject, builder);
    }

    public SOQL with(SObjectField field) {
        builder.fields.with(field);
        return this;
    }

    public SOQL with(SObjectField field1, SObjectField field2) {
        return with(field1).with(field2);
    }

    public SOQL with(SObjectField field1, SObjectField field2, SObjectField field3) {
        return with(field1, field2).with(field3);
    }

    public SOQL with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
        return with(field1, field2, field3).with(field4);
    }

    public SOQL with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
        return with(field1, field2, field3, field4).with(field5);
    }

    public SOQL with(List<SObjectField> fields) {
        builder.fields.with(fields);
        return this;
    }

    public SOQL with(Iterable<String> fields) {
        return with(String.join(fields, ','));
    }

    public SOQL with(String fields) {
        builder.fields.with(fields);
        return this;
    }

    public SOQL with(SObjectField field, String alias) {
        builder.fields.with(field, alias);
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

    public SOQL grouping(SObjectField field, String alias) {
        builder.fields.grouping(field, alias);
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

    public SOQL whereAre(FilterGroup filterGroup) {
        builder.conditions.add(filterGroup);
        return this;
    }

    public SOQL whereAre(Filter filter) {
        builder.conditions.add(filter);
        return this;
    }

    public SOQL whereAre(String conditions) {
        builder.conditions.add(conditions);
        return this;
    }

    public SOQL conditionLogic(String conditionLogic) {
        builder.conditions.conditionLogic(conditionLogic);
        return this;
    }

    public SOQL anyConditionMatching() {
        builder.conditions.anyConditionMatching();
        return this;
    }

    public SOQL groupBy(SObjectField field) {
        builder.groupBy.with(field);
        builder.fields.withAggregatedField(field);
        return this;
    }

    public SOQL groupByRollup(SObjectField field) {
        builder.groupBy.rollup(field);
        builder.fields.withAggregatedField(field);
        return this;
    }

    public SOQL groupByCube(SObjectField field) {
        builder.groupBy.cube(field);
        builder.fields.withAggregatedField(field);
        return this;
    }

    public SOQL orderBy(String field) {
        builder.orderBys.newOrderBy().with(field);
        return this;
    }

    public SOQL orderBy(String field, String direction) {
        builder.orderBys.newOrderBy().with(field).sortingOrder(direction);
        return this;
    }

    public SOQL orderBy(SObjectField field) {
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

    public SOQL systemMode() {
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

    public Boolean doExist() {
        builder.fields.clearAllFields(); // other fields not needed
        return toList().size() > 0;
    }

    public override String toString() {
        return builder.toString();
    }

    public Object toValueOf(SObjectField fieldToExtract) {
        builder.fields.clearAllFields(); // other fields not needed
        return with(fieldToExtract).toObject()?.get(fieldToExtract);
    }

    public Set<String> toValuesOf(SObjectField fieldToExtract) {
        // https://salesforce.stackexchange.com/questions/393308/get-a-list-of-one-column-from-a-soql-result
        builder.fields.clearAllFields(); // other fields not needed
        return new Map<String, SObject>(with(fieldToExtract, 'Id').groupBy(fieldToExtract).toAggregated()).keySet();
    }

    public Integer toInteger() {
        if (!builder.fields.hasCount()) {
            count();
        }
        return executor.toInteger();
    }

    public SObject toObject() {
        return executor.toObject();
    }

    public List<SObject> toList() {
        return executor.toList();
    }

    public List<AggregateResult> toAggregated() {
        return (List<AggregateResult>) toList();
    }

    public Map<Id, SObject> toMap() {
        return executor.toMap();
    }

    public Map<String, SObject> toMap(SObjectField keyField) {
        with(keyField);
        return executor.toMap(keyField);
    }

    public Map<String, String> toMap(SObjectField keyField, SObjectField valueField) {
        builder.fields.clearAllFields(); // other fields not needed
        with(keyField, valueField);
        return executor.toMap(keyField, valueField);
    }

    public Map<String, List<SObject>> toAggregatedMap(SObjectField keyField) {
        with(keyField);
        return executor.toAggregatedMap(keyField);
    }

    public Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField) {
        builder.fields.clearAllFields(); // other fields not needed
        with(keyField, valueField);
        return executor.toAggregatedMap(keyField, valueField);
    }

    public Database.QueryLocator toQueryLocator() {
        return executor.toQueryLocator();
    }

    public SOQL byId(SObject record) {
        return byId(record.Id);
    }

    public SOQL byId(Id recordId) {
        return whereAre(Filter.id().equal(recordId));
    }

    public SOQL byIds(Iterable<Id> recordIds) {
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

        public QMainFilterGroup conditions {
            get {
                if (clauses[4] == null) {
                    clauses.set(4, new QMainFilterGroup());
                }
                return (QMainFilterGroup) clauses[4];
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
        private Set<String> fields = new Set<String>();
        private Set<String> aggregatedFields = new Set<String>();

        public void count() {
            count('COUNT()');
        }

        public void count(SObjectField field) {
            count('COUNT(' + field + ')');
        }

        public void count(SObjectField field, String alias) {
            count('COUNT(' + field + ') ' + alias);
            fields.add('COUNT(' + field + ') ' + alias);
        }

        private void count(String count) {
            withAggregatedField(count);
            fields.add(count);
        }

        public void grouping(SObjectField field, String alias) {
            withAggregatedField('GROUPING(' + field + ') ' + alias);
            fields.add('GROUPING(' + field + ') ' + alias);
        }

        public void with(SObjectField field, String alias) {
            withAggregatedField(field + ' ' + alias);
            fields.add(field + ' ' + alias);
        }

        public void withAggregatedField(SObjectField field) {
            withAggregatedField(field.getDescribe().getName());
        }

        public void withAggregatedField(String field) {
            aggregatedFields.add(field);
        }

        public void with(String stringFields) {
            // To avoid field duplicates in query
            fields.addAll(stringFields.deleteWhitespace().split(','));
        }

        public void with(List<SObjectField> fields) {
            for (SObjectField field : fields) {
                with(field);
            }
        }

        public void with(SObjectField field) {
            fields.add(field.getDescribe().getName());
        }

        public void with(String relationshipPath, List<SObjectField> fields) {
            for (SObjectField field : fields) {
                with(relationshipPath, field);
            }
        }

        public void with(String relationshipPath, SObjectField field) {
            fields.add(relationshipPath + '.' + field);
        }

        public void clearAllFields() {
            fields.clear();
        }

        public Boolean hasCount() {
            return !aggregatedFields.isEmpty();
        }

        public override String toString() {
            removeNotAggregatedFieldsFromAggregateSoql();

            if (fields.isEmpty()) {
                return 'SELECT Id';
            }

            return 'SELECT ' + String.join(fields, ', ');
        }

        public void removeNotAggregatedFieldsFromAggregateSoql() {
            if (aggregatedFields.isEmpty()) {
                return;
            }
            // Clear not grouped or aggregated fields to avoid "Field must be grouped or aggregated" error
            for (String field : fields) {
                if (!aggregatedFields.contains(field)) {
                    fields.remove(field);
                }
            }
        }
    }

    private class QSubQuery implements SubQuery {
        private QueryBuilder builder;

        public SubQuery of(String ofObject) {
            builder = new QueryBuilder(ofObject);
            return this;
        }

        public SubQuery with(SObjectField field) {
            builder.fields.with(field);
            return this;
        }

        public SubQuery with(SObjectField field1, SObjectField field2) {
            return with(field1).with(field2);
        }

        public SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3) {
            return with(field1, field2).with(field3);
        }

        public SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
            return with(field1, field2, field3).with(field4);
        }

        public SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
            return with(field1, field2, field3, field4).with(field5);
        }

        public SubQuery with(List<SObjectField> fields) {
            builder.fields.with(fields);
            return this;
        }

        public SubQuery with(String relationshipName, List<SObjectField> fields) {
            builder.fields.with(relationshipName, fields);
            return this;
        }

        public SubQuery with(SubQuery subQuery) {
            builder.subQueries.add(subQuery);
            return this;
        }

        public SubQuery whereAre(FilterGroup filterGroup) {
            builder.conditions.add(filterGroup);
            return this;
        }

        public SubQuery whereAre(Filter filter) {
            builder.conditions.add(filter);
            return this;
        }

        public SubQuery orderBy(SObjectField field) {
            builder.orderBys.newOrderBy().with(field);
            return this;
        }

        public SubQuery orderBy(String relationshipName, SObjectField field) {
            builder.orderBys.newOrderBy().with(relationshipName, field);
            return this;
        }

        public SubQuery sortDesc() {
            builder.latestOrderBy.sortDesc();
            return this;
        }

        public SubQuery nullsLast() {
            builder.latestOrderBy.nullsLast();
            return this;
        }

        public SubQuery setLimit(Integer amount) {
            builder.soqlLimit.max(amount);
            return this;
        }

        public SubQuery offset(Integer startingRow) {
            builder.soqlOffset.offset(startingRow);
            return this;
        }

        public SubQuery forReference() {
            builder.soqlFor.forReference();
            return this;
        }

        public SubQuery forView() {
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

    private virtual class QFilterGroup implements FilterGroup {
        private List<FilterClause> queryConditions = new List<FilterClause>();
        private String order;
        private String connector = 'AND';

        public FilterGroup add(FilterGroup filterGroup) {
            return add(new QFilterGroupAdapter(filterGroup));
        }

        public FilterGroup add(Filter filter) {
            return add(new QFilterAdapter(filter));
        }

        public FilterGroup add(String dynamicCondition) {
            return add(new QStringAdapter(dynamicCondition));
        }

        public FilterGroup add(FilterClause condition) {
            if (condition.isEmpty()) {
                return this;
            }
            queryConditions.add(condition);
            return this;
        }

        public FilterGroup anyConditionMatching() {
            connector = 'OR';
            return this;
        }

        public FilterGroup conditionLogic(String order) {
            this.order = order;
            return this;
        }

        public Boolean hasValues() {
            return !queryConditions.isEmpty();
        }

        public virtual override String toString() {
            return '(' + buildNested() + ')';
        }

        private void setDefaultOrderWhenNotSpecified() {
            if (String.isNotEmpty(order)) {
                return;
            }

            List<String> defaultOrder = new List<String>();

            for (Integer i = 0; i < queryConditions.size(); i++) {
                defaultOrder.add(String.valueOf(i + 1));
            }

            order = String.join(defaultOrder, ' ' + connector + ' ');
        }

        public String buildNested() {
            setDefaultOrderWhenNotSpecified(); // e.g (0 AND 1 AND 2)
            addSpecialCharactersToOrder(); // e.g ({0} AND ({1} AND {2}))

            return String.format(order, queryConditions);
        }

        private void addSpecialCharactersToOrder() {
            for (Integer i = 0; i < queryConditions.size(); i++) {
                order = order.replace(String.valueOf(i + 1), '{' + i + '}');
            }
        }
    }

    private class QMainFilterGroup extends QFilterGroup implements QueryClause {
        public override String toString() {
            if (!hasValues()) {
                return '';
            }

            return 'WHERE ' + buildNested();
        }
    }

    private class QFilterGroupAdapter implements FilterClause {
        private FilterGroup filterGroup;

        public QFilterGroupAdapter(FilterGroup filterGroup) {
            this.filterGroup = filterGroup;
        }

        public Boolean isEmpty() {
            return !filterGroup.hasValues();
        }

        public override String toString() {
            return filterGroup.toString();
        }
    }

    private class QFilterAdapter implements FilterClause {
        private Filter filter;

        public QFilterAdapter(Filter filter) {
            this.filter = filter;
        }

        public Boolean isEmpty() {
            return !filter.hasValue();
        }

        public override String toString() {
            return filter.toString();
        }
    }

    private class QStringAdapter implements FilterClause {
        private String conditionString;

        public QStringAdapter(String dynamicCondition) {
            conditionString = dynamicCondition;
        }

        public Boolean isEmpty() {
            return String.isEmpty(conditionString);
        }

        public override String toString() {
            return conditionString;
        }
    }

    private class QFilter implements Filter {
        private String field;
        private String comperator;
        private Object value;
        private String wrapper = '{0}';
        private Boolean skipBinding = false;

        public Filter id() {
            return with('Id');
        }

        public Filter recordType() {
            return with('RecordType.DeveloperName');
        }

        public Filter name() {
            return with('Name');
        }

        public Filter with(SObjectField field) {
            return with(field.getDescribe().getName());
        }

        public Filter with(String relationshipName, SObjectField field) {
            return with(relationshipName + '.' + field);
        }

        public Filter with(String field) {
            this.field = field;
            return this;
        }

        public Filter isNull() {
            return equal(null);
        }

        public Filter isNotNull() {
            return notEqual(null);
        }

        public Filter isTrue() {
            return equal(true);
        }

        public Filter isFalse() {
            return equal(false);
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

        public Filter lessOrEqual(Object value) {
            return set('<=', value);
        }

        public Filter greaterOrEqual(Object value) {
            return set('>=', value);
        }

        public Filter containsSome(List<String> values) {
            return set('LIKE', values);
        }

        public Filter contains(String value) {
            return contains('%', formattedString(value), '%');
        }

        public Filter notContains(String value) {
            return notLike().contains(value);
        }

        public Filter endsWith(String value) {
            return contains('%', formattedString(value), '');
        }

        public Filter notEndsWith(String value) {
            return notLike().endsWith(value);
        }

        public Filter startsWith(String value) {
            return contains('', formattedString(value), '%');
        }

        public Filter notStartsWith(String value) {
            return notLike().startsWith(value);
        }

        public Filter contains(String prefix, String value, String suffix) {
            return set('LIKE', prefix + formattedString(value) + suffix);
        }

        public Filter notContains(String prefix, String value, String suffix) {
            return notLike().contains(prefix, value, suffix);
        }

        private String formattedString(String value) {
            return value == null ? value : String.escapeSingleQuotes(value.trim());
        }

        public Filter isIn(Iterable<Object> iterable) {
            return set('IN', iterable);
        }

        public Filter isIn(InnerJoin joinQuery) {
            skipBinding = true;
            return set('IN', joinQuery);
        }

        private Filter notLike() {
            this.wrapper = '(NOT {0})';
            return this;
        }

        public Filter notIn(Iterable<Object> iterable) {
            return set('NOT IN', iterable);
        }

        public Filter notIn(InnerJoin joinQuery) {
            skipBinding = true;
            return set('NOT IN', joinQuery);
        }

        public Filter includesAll(Iterable<String> iterable) {
            // Bind expressions can't be used with other clauses, such as INCLUDES.
            skipBinding = true;
            return set('INCLUDES', '(\'' + String.join(iterable, ';') + '\')');
        }

        public Filter includesSome(Iterable<String> iterable) {
            // Bind expressions can't be used with other clauses, such as INCLUDES.
            skipBinding = true;
            return set('INCLUDES', '(\'' + String.join(iterable, '\', \'') + '\')');
        }

        public Filter excludesAll(Iterable<String> iterable) {
            // Bind expressions can't be used with other clauses, such as EXCLUDES.
            skipBinding = true;
            return set('EXCLUDES', '(\'' + String.join(iterable, '\', \'') + '\')');
        }

        public Filter excludesSome(Iterable<String> iterable) {
            // Bind expressions can't be used with other clauses, such as EXCLUDES.
            skipBinding = true;
            return set('EXCLUDES', '(\'' + String.join(iterable, ';') + '\')');
        }

        private Filter set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public Boolean hasValue() {
            return String.isNotEmpty(field);
        }

        public Filter ignoreWhen(Boolean logicExpression) {
            if (logicExpression) {
                // Set field as empty to meet hasValue and ignore condition
                with('');
            }
            return this;
        }

        public Filter asDateLiteral() {
            // Date Literals can't be binded
            skipBinding = true;
            return this;
        }

        public override String toString() {
            if (skipBinding) {
                return String.format(wrapper, new List<String>{ field + ' ' + comperator + ' ' + value });
            }

            return String.format(wrapper, new List<String>{ field + ' ' + comperator + ' :' + binder.bind(value) });
        }
    }

    private class QJoinQuery implements InnerJoin {
        private QueryBuilder builder;

        public InnerJoin of(SObjectType ofObject) {
            builder = new QueryBuilder(ofObject.getDescribe().getName());
            return this;
        }

        public InnerJoin with(SObjectField field) {
            builder.fields.with(field);
            return this;
        }

        public InnerJoin whereAre(FilterGroup filterGroup) {
            builder.conditions.add(filterGroup);
            return this;
        }

        public InnerJoin whereAre(Filter filter) {
            builder.conditions.add(filter);
            return this;
        }

        public override String toString() {
            return '(' + builder.toString() + ')';
        }
    }

    private class QGroupBy implements QueryClause {
        private Set<String> groupByFields = new Set<String>();
        private String groupByFunction = '';

        public void with(SObjectField field) {
            setGroupByFunction('{0}');
            groupByFields.add(field.getDescribe().getName());
        }

        public void rollup(SObjectField field) {
            setGroupByFunction('ROLLUP({0})');
            groupByFields.add(field.getDescribe().getName());
        }

        public void cube(SObjectField field) {
            setGroupByFunction('CUBE({0})');
            groupByFields.add(field.getDescribe().getName());
        }

        public void setGroupByFunction(String newGroupByFunction) {
            if (String.isNotEmpty(groupByFunction) && groupByFunction != newGroupByFunction) {
                QueryException e = new QueryException();
                e.setMessage('You cant use GROUP BY, GROUP BY ROLLUP and GROUP BY CUBE in the same query.');
                throw e;
            }
            this.groupByFunction = newGroupByFunction;
        }

        public override String toString() {
            return 'GROUP BY ' + String.format(groupByFunction, new List<String>{ String.join(groupByFields, ', ') });
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

        public void with(SObjectField field) {
            with(field.getDescribe().getName());
        }

        public void with(String relationshipName, SObjectField field) {
            with(relationshipName + '.' + field);
        }

        public QOrderBy with(String field) {
            orderField = field;
            return this;
        }

        public void sortDesc() {
            sortingOrder('DESC');
        }

        public void sortingOrder(String direction) {
            sortingOrder = direction;
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
        private final Map<String, List<SObject>> sObjectsMocks = new Map<String, List<SObject>>();
        private final Map<String, Integer> countMocks = new Map<String, Integer>();

        public void setMock(String mockId, List<SObject> records) {
            sObjectsMocks.put(mockId, records);
        }

        public void setCountMock(String mockId, Integer amount) {
            countMocks.put(mockId, amount);
        }

        public Boolean hasMock(String mockId) {
            return sObjectsMocks.containsKey(mockId);
        }

        public Boolean hasCountMock(String mockId) {
            return countMocks.containsKey(mockId);
        }

        public List<SObject> getSObjectsMock(String mockId) {
            return sObjectsMocks.get(mockId);
        }

        public Integer getCountMock(String mockId) {
            return countMocks.get(mockId);
        }
    }

    private inherited sharing class Executor {
        private AccessLevel accessMode = AccessLevel.USER_MODE; // The object permissions, field-level security, sharing rules are enforced.
        private DatabaseQuery sharingExecutor = new InheritedSharing();
        private AccessType accessType;
        private String mockId;
        private String ofObject;
        private QueryBuilder builder;

        public Executor(String ofObject, QueryBuilder builder) {
            this.ofObject = ofObject;
            this.builder = builder;
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

        public SObject toObject() {
            List<SObject> records = toList();

            if (records.size() > 1) {
                QueryException e = new QueryException();
                e.setMessage('List has more than 1 row for assignment to SObject');
                throw e;
            }

            if (records.size() == 0) {
                return null; // handle: List has no rows for assignment to SObject
            }

            return records[0];
        }

        public List<SObject> toList() {
            if (mock.hasMock(mockId)) {
                return mock.getSObjectsMock(mockId);
            }

            if (accessType == null) {
                return sharingExecutor.toSObjects(builder.toString(), binder.getBindingMap(), accessMode);
            }

            return Security.stripInaccessible(
                accessType,
                sharingExecutor.toSObjects(builder.toString(), binder.getBindingMap(), accessMode)
            ).getRecords();
        }

        public Map<Id, SObject> toMap() {
            Map<Id, SObject> recordPerId = (Map<Id, SObject>) Type.forName('Map<Id, ' + ofObject  + ' >').newInstance();
            recordPerId.putAll(toList());
            return recordPerId;
        }

        public Map<String, SObject> toMap(SObjectField keyField) {
            Map<String, SObject> recordPerCustomKey = (Map<String, SObject>) Type.forName('Map<String, ' + ofObject  + ' >').newInstance();

            for (SObject record : toList()) {
                recordPerCustomKey.put(String.valueOf(record.get(keyField)), record);
            }

            return recordPerCustomKey;
        }

        public Map<String, String> toMap(SObjectField keyField, SObjectField valueField) {
            Map<String, String> customValuePerCustomKey = new Map<String, String>();

            for (SObject record : toList()) {
                customValuePerCustomKey.put(String.valueOf(record.get(keyField)), String.valueOf(record.get(valueField)));
            }

            return customValuePerCustomKey;
        }

        public Map<String, List<SObject>> toAggregatedMap(SObjectField keyField) {
            Map<String, List<SObject>> recordsPerCustomKey = (Map<String, List<SObject>>) Type.forName('Map<String, List<' + ofObject  + ' >>').newInstance();

            for (SObject record : toList()) {
                String key = String.valueOf(record.get(keyField));

                if (!recordsPerCustomKey.containsKey(key)) {
                    recordsPerCustomKey.put(key, new List<SObject>());
                }

                recordsPerCustomKey.get(key).add(record);
            }

            return recordsPerCustomKey;
        }

        public Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField) {
            Map<String, List<String>> customValuesPerCustomKey = new Map<String, List<String>>();

            for (SObject record : toList()) {
                String key = String.valueOf(record.get(keyField));

                if (!customValuesPerCustomKey.containsKey(key)) {
                    customValuesPerCustomKey.put(key, new List<String>());
                }

                customValuesPerCustomKey.get(key).add(String.valueOf(record.get(valueField)));
            }

            return customValuesPerCustomKey;
        }

        public Integer toInteger() {
            if (mock.hasCountMock(mockId)) {
                return mock.getCountMock(mockId);
            }

            return sharingExecutor.toInteger(builder.toString(), binder.getBindingMap(), accessMode);
        }

        public Database.QueryLocator toQueryLocator() {
            return Database.getQueryLocatorWithBinds(builder.toString(), binder.getBindingMap(), accessMode);
        }
    }

    private interface DatabaseQuery {
        List<SObject> toSObjects(String query, Map<String, Object> binding, AccessLevel accessLevel);
        Integer toInteger(String query, Map<String, Object> binding, AccessLevel accessLevel);
    }

    private inherited sharing class InheritedSharing implements DatabaseQuery {
        public List<SObject> toSObjects(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer toInteger(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private without sharing class WithoutSharing implements DatabaseQuery {
        public List<SObject> toSObjects(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer toInteger(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }

    private with sharing class WithSharing implements DatabaseQuery {
        public List<SObject> toSObjects(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.queryWithBinds(query, binding, accessLevel);
        }

        public Integer toInteger(String query, Map<String, Object> binding, AccessLevel accessLevel) {
            return Database.countQueryWithBinds(query, binding, accessLevel);
        }
    }
}
