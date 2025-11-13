global interface SubQuery {
    SubQuery of(String ofObject);
    // SELECT
    SubQuery with(SObjectField field);
    SubQuery with(SObjectField field1, SObjectField field2);
    SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3);
    SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
    SubQuery with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
    SubQuery with(Iterable<SObjectField> fields);
    SubQuery with(String fields);
    SubQuery with(String relationshipName, Iterable<SObjectField> fields);
    SubQuery with(SubQuery subQuery);
    // WHERE
    SubQuery whereAre(FilterGroup filterGroup);
    SubQuery whereAre(Filter filter);
    // ORDER BY
    SubQuery orderBy(SObjectField field);
    SubQuery orderBy(String field);
    SubQuery orderBy(String relationshipName, SObjectField field);
    SubQuery sortDesc();
    SubQuery sort(String direction);
    SubQuery nullsLast();
    // LIMIT
    SubQuery setLimit(Integer amount);
    // OFFSET
    SubQuery offset(Integer startingRow);
    // FOR
    SubQuery forReference();
    SubQuery forView();
    // ADDITIONAL
    String getChildRelationshipName();
}