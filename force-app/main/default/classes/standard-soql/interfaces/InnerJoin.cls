global interface InnerJoin {
    InnerJoin of(SObjectType ofObject);
    // SELECT
    InnerJoin with(SObjectField field);
    // WHERE
    InnerJoin whereAre(FilterGroup filterGroup);
    InnerJoin whereAre(Filter filter);
}