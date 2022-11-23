public with sharing class QB_Preview {
    public static void displayQuery(String query) {
        System.debug('\n\n============ Query Preview ============\n\n' + query + '\n=======================================\n');
    }

    public static void displayResults(List<sObject> results) {
        System.debug('\n\n============ Result Preview ============\n\n' + JSON.SerializePretty(results) + '\n\n=======================================\n');
    }
}
