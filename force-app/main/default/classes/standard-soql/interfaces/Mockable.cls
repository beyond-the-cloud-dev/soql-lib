global interface Mockable {
    // SObject
    Mockable thenReturn(SObject record);
    Mockable thenReturn(List<SObject> records);
    // AggregateResultProxy
    Mockable thenReturn(List<Map<String, Object>> aggregatedResults);
    Mockable thenReturn(Map<String, Object> aggregatedResult);
    // Count
    Mockable thenReturn(Integer count);
    // Exception
    void throwException();
    void throwException(String message);
}