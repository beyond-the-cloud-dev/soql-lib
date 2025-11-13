global interface FilterGroup {
    // ADD CONDITION
    FilterGroup add(FilterGroup filterGroup);
    FilterGroup add(Filter filter);
    FilterGroup add(String dynamicCondition);
    FilterGroup add(List<Filter> filters);
    FilterGroup add(List<String> dynamicConditions);
    // ORDER
    FilterGroup anyConditionMatching();
    FilterGroup conditionLogic(String order);
    // ADDITIONAL
    FilterGroup ignoreWhen(Boolean logicExpression);

    Boolean hasValues();
}