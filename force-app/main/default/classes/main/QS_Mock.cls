@IsTest
public class QS_Mock {
    private static Map<String, List<sObject>> mocks = new Map<String, List<sObject>>();
    private static Map<String, Integer> countMocks = new Map<String, Integer>();

    public static void setMock(String queryIdentifier, List<sObject> records) {
        mocks.put(queryIdentifier, records);
    }

    public static void setCountMock(String queryIdentifier, Integer amount) {
        countMocks.put(queryIdentifier, amount);
    }

    public static List<sObject> getMock(String queryIdentifier) {
        return mocks.get(queryIdentifier);
    }

    public static Integer getCountMock(String queryIdentifier) {
        return countMocks.get(queryIdentifier);
    }

    public static Boolean containsMock(String queryIdentifier) {
        return mocks.get(queryIdentifier) != null;
    }

    public static Boolean containsCountMock(String queryIdentifier) {
        return countMocks.get(queryIdentifier) != null;
    }
}
