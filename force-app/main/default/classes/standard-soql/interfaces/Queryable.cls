global interface Queryable {
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
    Queryable with(String relationshipName, Iterable<SObjectField> fields);
    Queryable with(SubQuery subQuery);
    Queryable withFieldSet(String fieldSetName);
    // SELECT - AGGREGATE FUNCTIONS
    Queryable count();
    Queryable count(SObjectField field);
    Queryable count(SObjectField field, String alias);
    Queryable count(String relationshipName, SObjectField field);
    Queryable count(String relationshipName, SObjectField field, String alias);
    Queryable avg(SObjectField field);
    Queryable avg(SObjectField field, String alias);
    Queryable avg(String relationshipName, SObjectField field);
    Queryable avg(String relationshipName, SObjectField field, String alias);
    Queryable countDistinct(SObjectField field);
    Queryable countDistinct(SObjectField field, String alias);
    Queryable countDistinct(String relationshipName, SObjectField field);
    Queryable countDistinct(String relationshipName, SObjectField field, String alias);
    Queryable min(SObjectField field);
    Queryable min(SObjectField field, String alias);
    Queryable min(String relationshipName, SObjectField field);
    Queryable min(String relationshipName, SObjectField field, String alias);
    Queryable max(SObjectField field);
    Queryable max(SObjectField field, String alias);
    Queryable max(String relationshipName, SObjectField field);
    Queryable max(String relationshipName, SObjectField field, String alias);
    Queryable sum(SObjectField field);
    Queryable sum(SObjectField field, String alias);
    Queryable sum(String relationshipName, SObjectField field);
    Queryable sum(String relationshipName, SObjectField field, String alias);
    // SELECT - GROUPING
    Queryable grouping(SObjectField field, String alias);
    // SELECT - toLabel
    Queryable toLabel(SObjectField field);
    Queryable toLabel(SObjectField field, String alias);
    Queryable toLabel(String field);
    Queryable toLabel(String field, String alias);
    // SELECT - FORMAT
    Queryable format(SObjectField field);
    Queryable format(SObjectField field, String alias);
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
    // PREDEFINED WHERE
    Queryable byId(SObject record);
    Queryable byId(Id recordId);
    Queryable byIds(Iterable<Id> recordIds);
    Queryable byIds(List<SObject> records);
    Queryable byRecordType(String recordTypeDeveloperName);
    // GROUP BY
    Queryable groupBy(SObjectField field);
    Queryable groupBy(String field);
    Queryable groupBy(String relationshipName, SObjectField field);
    Queryable groupByRollup(SObjectField field);
    Queryable groupByRollup(String relationshipName, SObjectField field);
    Queryable groupByCube(SObjectField field);
    Queryable groupByCube(String relationshipName, SObjectField field);
    // HAVING
    Queryable have(HavingFilterGroup havingFilterGroup);
    Queryable have(HavingFilter havingFilter);
    Queryable have(String havingConditions);
    Queryable havingConditionLogic(String havingConditionsOrder);
    Queryable anyHavingConditionMatching();
    // WITH DATA CATEGORY
    Queryable withDataCategory(DataCategoryFilter dataCategoryFilter);
    // ORDER BY
    Queryable orderBy(SObjectField field);
    Queryable orderBy(String field);
    Queryable orderBy(String field, String direction);
    Queryable orderBy(String relationshipName, SObjectField field);
    Queryable orderByCount(SObjectField field);
    Queryable sortDesc();
    Queryable sort(String direction);
    Queryable nullsLast();
    Queryable nullsOrder(String nullsOrder);
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
    Queryable userMode();
    Queryable systemMode();
    Queryable stripInaccessible();
    Queryable stripInaccessible(AccessType accessType);
    // SHARING MODE
    Queryable withSharing();
    Queryable withoutSharing();
    // MOCKING
    Queryable mockId(String queryIdentifier);
    // DEBUGGING
    Queryable preview();
    // SOBJECT
    SObject toObject();
    // LIST
    List<SObject> toList();
    // COUNT
    Integer toInteger();
    // QUERY LOCATOR
    Database.QueryLocator toQueryLocator();
    // DO EXIST
    Boolean doExist();
    // AGGREGATE RESULTS
    List<AggregateResult> toAggregated();
    List<AggregateResultProxy> toAggregatedProxy(); // use when you need mocking
    // STRING
    String toString();
    // IDS
    Id toId();
    Set<Id> toIds();
    Set<Id> toIdsOf(SObjectField field);
    Set<Id> toIdsOf(String relationshipName, SObjectField targetKeyField);
    // VALUE
    Object toValueOf(SObjectField fieldToExtract);
    Set<String> toValuesOf(SObjectField fieldToExtract);
    Set<String> toValuesOf(String relationshipName, SObjectField targetKeyField);
    // ID MAP
    Map<Id, SObject> toMap();
    Map<Id, SObject> toIdMapBy(SObjectField field);
    Map<Id, SObject> toIdMapBy(String relationshipName, SObjectField targetKeyField);
    Map<Id, List<SObject>> toAggregatedIdMapBy(SObjectField keyField);
    Map<Id, List<SObject>> toAggregatedIdMapBy(String relationshipName, SObjectField targetKeyField);
    // VALUE MAP
    Map<String, SObject> toMap(SObjectField keyField);
    Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField);
    Map<String, String> toMap(SObjectField keyField, SObjectField valueField);
    Map<String, List<SObject>> toAggregatedMap(SObjectField keyField);
    Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField);
    Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField);
    Map<String, List<String>> toAggregatedMap(SObjectField keyField, String relationshipName, SObjectField targetKeyField);

    // for internal use
    Map<String, Object> binding();
}