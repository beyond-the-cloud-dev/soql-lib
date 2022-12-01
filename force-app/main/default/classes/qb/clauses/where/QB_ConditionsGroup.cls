public class QB_ConditionsGroup implements QB_ConditionClause, QB_QueryClause {
    private List<QB_ConditionClause> queryConditions = new List<QB_ConditionClause>();
    private String conditionOrder = '';

    public QB_ConditionsGroup condition(QB_ConditionClause condition) {
        this.queryConditions.add(condition);
        return this;
    }

    public QB_ConditionsGroup conditionsOrder(String conditionsOrder) {
        this.conditionOrder = conditionsOrder;
        return this;
    }

    public String build() {
        if (this.queryConditions.isEmpty()) {
            return '';
        }

        if (String.isEmpty(this.conditionOrder)) {
            this.setDefaultOrder();
        }

        return 'WHERE ' + this.buildConditions(executor).replaceFirst('WHERE ', '');
    }

    private void setDefaultOrder() {
        List<String> defaultConditionsOrder = new List<String>();

        for (Integer i = 0; i < this.queryConditions.size(); i++) {
            defaultConditionsOrder.add(String.valueOf(i + 1));
        }

        this.conditionOrder = '(' + String.join(defaultConditionsOrder, ' AND ') + ')';
    }

    private String buildConditions(QB_QueryExecutor executor) {
        String finalCondition = addSpecialCharactersToOrder(); // e.g (*1* AND (*2* OR *3*))

        for (Integer i = 0; i < this.queryConditions.size(); i++) {
            String formattedConditionNumber = addSpecialCharacters(String.valueOf(i + 1)); // e.g *1*

            finalCondition = finalCondition.replace(formattedConditionNumber, this.queryConditions.get(i).build(executor));
        }

        return finalCondition;
    }

    private String addSpecialCharactersToOrder() {
        String formattedConditionsOrder = this.conditionOrder;

        for (Integer i = 1; i <= this.queryConditions.size(); i++) {
            String conditionNumber = String.valueOf(i);

            formattedConditionsOrder = formattedConditionsOrder.replace(conditionNumber, addSpecialCharacters(conditionNumber));
        }

        return '(' +formattedConditionsOrder  + ')'; // e.g (*1* AND (*2* OR *3*))
    }

    private String addSpecialCharacters(String condition) {
        return '*' + condition.trim() + '*';
    }
}
