public class QB_ConditionsGroup extends QB_QueryClause {
    private List<QB_QueryClause> queryConditions = new List<QB_QueryClause>();
    private String conditionOrder = '';
    Boolean isNested = false;

    public QB_ConditionsGroup add(QB_QueryClause condition) {
        this.isNested = true;
        this.queryConditions.add(condition);
        return this;
    }

    public QB_ConditionsGroup order(String conditionsOrder) {
        this.conditionOrder = conditionsOrder;
        return this;
    }

    public override String build() {
        if (String.isEmpty(this.conditionOrder)) {
            this.conditionOrder = this.buildDefaultConditionsOrder(this.queryConditions);
        }

        String query = '';

        if (!isNested) {
            query += 'WHERE ';
        }

        return query + this.getConditionsWithFilteringExpressions(this.queryConditions, this.conditionOrder);
    }

    public override String validate() {
        if (String.isEmpty(this.conditionOrder)) {
            return this.validateChildren(this.queryConditions);
        }

        String errors = '';

        if (!Pattern.matches('(OR|AND|\\ |\\d|\\(|\\))+', this.conditionOrder)) {
            errors += 'Invalid condition order. You are allowed to use only (, ), numbers, AND, OR. \n';
        }

        if (this.conditionOrder.countMatches('(') != this.conditionOrder.countMatches(')')) {
            errors += 'Invalid condition order. Missing open or close bracket. \n';
        }

        for (Integer i = 0; i < this.queryConditions.size(); i++) {
            if (!this.conditionOrder.contains(String.valueOf(i + 1))) {
                errors += 'Invalid condition order. Condition order not contains all conditions. \n';
                break;
            }
        }

        return errors + this.validateChildren(this.queryConditions);
    }

    public String validateChildren(List<QB_QueryClause> queryConditions) {
        String queryErrors = '';

        for (QB_QueryClause clause : this.queryConditions) {
            queryErrors += clause.validate();
        }

        return queryErrors;
    }

    public String buildDefaultConditionsOrder(List<QB_QueryClause> queryConditions) {
        List<String> defaultConditionsOrder = new List<String>();

        for (Integer i = 0; i < queryConditions.size(); i++) {
            defaultConditionsOrder.add(String.valueOf(i + 1));
        }

        return '(' + String.join(defaultConditionsOrder, ' AND ') + ')';
    }

    public String getConditionsWithFilteringExpressions(List<QB_QueryClause> queryConditions, String conditionsOrder) {
        String finalCondition = getConditionsOrderWithSpecialCharacters(queryConditions, conditionsOrder); // e.g (*1* AND (*2* OR *3*))

        for (Integer i = 0; i < queryConditions.size(); i++) {
            String formattedConditionNumber = addSpecialCharacters(String.valueOf(i + 1)); // e.g *1*

            finalCondition = finalCondition.replace(formattedConditionNumber, queryConditions.get(i).build());
        }

        return finalCondition;
    }

    private String getConditionsOrderWithSpecialCharacters(List<QB_QueryClause> queryConditions, String conditionsOrder) {
        String formattedConditionsOrder = conditionsOrder;

        for (Integer i = 1; i <= queryConditions.size(); i++) {
            String conditionNumber = String.valueOf(i);

            formattedConditionsOrder = formattedConditionsOrder.replace(conditionNumber, addSpecialCharacters(conditionNumber));
        }

        return '(' + formattedConditionsOrder + ')'; // e.g (*1* AND (*2* OR *3*))
    }

    private static String addSpecialCharacters(String condition) {
        return '*' + condition.trim() + '*';
    }
}
