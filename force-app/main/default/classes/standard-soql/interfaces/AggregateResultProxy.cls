global interface AggregateResultProxy {
    Object get(String field);
    Map<String, Object> getPopulatedFieldsAsMap();
}