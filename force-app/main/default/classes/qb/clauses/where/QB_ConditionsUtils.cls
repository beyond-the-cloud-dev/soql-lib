public with sharing class QB_ConditionsUtils {
    public static String buildDefaultConditionsOrder(List<QB_QueryClause> queryConditions) {
        List<String> defaultConditionsOrder = new List<String>();

        for (Integer i = 0; i < queryConditions.size(); i++) {
            defaultConditionsOrder.add(String.valueOf(i + 1));
        }

        return '(' + String.join(defaultConditionsOrder, ' AND ') + ')';
    }

    public static String getConditionsWithFilteringExpressions(List<QB_QueryClause> queryConditions, String conditionsOrder) {
        String finalCondition = getConditionsOrderWithSpecialCharacters(queryConditions, conditionsOrder);

        for (Integer i = 0; i < queryConditions.size(); i++) {
            String formattedConditionNumber = addSpecialCharacters(String.valueOf(i + 1));

            finalCondition = finalCondition.replace(formattedConditionNumber, queryConditions.get(i).build());
        }

        return finalCondition;
    }

    private static String getConditionsOrderWithSpecialCharacters(List<QB_QueryClause> queryConditions, String conditionsOrder) {
        String formattedConditionsOrder = conditionsOrder;

        for (Integer i = 1; i <= queryConditions.size(); i++) {
            String conditionNumber = String.valueOf(i);

            formattedConditionsOrder = formattedConditionsOrder.replace(conditionNumber, addSpecialCharacters(conditionNumber));
        }

        return formattedConditionsOrder; // e.g (*1* AND (*2* OR *3*))
    }

    private static String addSpecialCharacters(String condition) {
        return '*' + condition.trim() + '*';
    }
}
