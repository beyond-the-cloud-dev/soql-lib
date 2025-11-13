global interface HavingFilter {
    // FIELDS
    HavingFilter with(SObjectField field);
    HavingFilter with(String field);
    HavingFilter count(SObjectField field);
    HavingFilter avg(SObjectField field);
    HavingFilter countDistinct(SObjectField field);
    HavingFilter min(SObjectField field);
    HavingFilter max(SObjectField field);
    HavingFilter sum(SObjectField field);
    // COMPARATORS
    HavingFilter isNull();
    HavingFilter isNotNull();
    HavingFilter isTrue();
    HavingFilter isFalse();
    HavingFilter equal(Object value);
    HavingFilter notEqual(Object value);
    HavingFilter lessThan(Object value);
    HavingFilter lessOrEqual(Object value);
    HavingFilter greaterThan(Object value);
    HavingFilter greaterOrEqual(Object value);
    HavingFilter contains(String value);
    HavingFilter contains(String prefix, String value, String suffix);
    HavingFilter notContains(String value);
    HavingFilter notContains(String prefix, String value, String suffix);
    HavingFilter startsWith(String value);
    HavingFilter notStartsWith(String value);
    HavingFilter endsWith(String value);
    HavingFilter notEndsWith(String value);
    HavingFilter isIn(Iterable<Object> iterable);
    HavingFilter notIn(Iterable<Object> iterable);

    Boolean hasValue();
}