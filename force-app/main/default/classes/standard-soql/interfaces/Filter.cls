global interface Filter {
    // FIELDS
    Filter id();
    Filter recordType();
    Filter name();
    Filter with(SObjectField field);
    Filter with(String field);
    Filter with(String relationshipName, SObjectField field);
    // COMPARATORS
    Filter isNull();
    Filter isNotNull();
    Filter isTrue();
    Filter isFalse();
    Filter equal(Object value);
    Filter notEqual(Object value);
    Filter lessThan(Object value);
    Filter lessOrEqual(Object value);
    Filter greaterThan(Object value);
    Filter greaterOrEqual(Object value);
    Filter containsSome(Iterable<String> values);
    Filter contains(String value);
    Filter contains(String prefix, String value, String suffix);
    Filter notContains(String value);
    Filter notContains(String prefix, String value, String suffix);
    Filter endsWith(String value);
    Filter notEndsWith(String value);
    Filter startsWith(String value);
    Filter notStartsWith(String value);
    Filter isIn(Iterable<Object> iterable);
    Filter isIn(InnerJoin joinQuery);
    Filter notIn(Iterable<Object> iterable);
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