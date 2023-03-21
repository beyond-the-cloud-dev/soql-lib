public class QB_Cache {
    private static Map<String, List<sObject>> soqlToCacheRecords = new Map<String, List<sObject>>();

    public static void save(String soql, List<sObject> records) {
        soqlToCacheRecords.put(soql, records);
    }

    public static Boolean contains(String soql) {
        return soqlToCacheRecords.containsKey(soql);
    }

    public static List<sObject> get(String soql) {
        return soqlToCacheRecords.get(soql);
    }
}
