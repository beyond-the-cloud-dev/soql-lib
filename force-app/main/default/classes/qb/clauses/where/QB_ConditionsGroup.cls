public class QB_ConditionsGroup extends QB_ConditionClause {
    private List<QB_ConditionClause> queryConditions = new List<QB_ConditionClause>();
    private String conditionOrder = '';
    Boolean isNested = true;

    public QB_ConditionsGroup add(QB_ConditionClause condition) {
        this.queryConditions.add(condition);
        return this;
    }

    public QB_ConditionsGroup order(String conditionsOrder) {
        this.conditionOrder = conditionsOrder;
        return this;
    }

    public QB_ConditionsGroup top() {
        this.isNested = false;
        return this;
    }

    public override String build() {
        if (String.isEmpty(this.conditionOrder)) {
            this.setDefaultOrder();
        }

        String query = '';

        if (!this.isNested) {
            query += 'WHERE ';
        }

        return query + this.buildConditions();
    }

    public override String validate() {
        if (String.isEmpty(this.conditionOrder)) {
            return this.validateChildren();
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

        return errors + this.validateChildren();
    }

    public String validateChildren() {
        String conditionsErrors = '';

        for (QB_ConditionClause qc : this.queryConditions) {
            conditionsErrors += qc.validate();
        }

        return conditionsErrors;
    }

    private void setDefaultOrder() {
        List<String> defaultConditionsOrder = new List<String>();

        for (Integer i = 0; i < this.queryConditions.size(); i++) {
            defaultConditionsOrder.add(String.valueOf(i + 1));
        }

        this.conditionOrder = '(' + String.join(defaultConditionsOrder, ' AND ') + ')';
    }

    private String buildConditions() {
        String finalCondition = addSpecialCharactersToOrder(); // e.g (*1* AND (*2* OR *3*))

        for (Integer i = 0; i < this.queryConditions.size(); i++) {
            String formattedConditionNumber = addSpecialCharacters(String.valueOf(i + 1)); // e.g *1*

            finalCondition = finalCondition.replace(formattedConditionNumber, this.queryConditions.get(i).build());
        }

        return finalCondition;
    }

    private String addSpecialCharactersToOrder() {
        String formattedConditionsOrder = this.conditionOrder;

        for (Integer i = 1; i <= this.queryConditions.size(); i++) {
            String conditionNumber = String.valueOf(i);

            formattedConditionsOrder = formattedConditionsOrder.replace(conditionNumber, addSpecialCharacters(conditionNumber));
        }

        return '(' + formattedConditionsOrder + ')'; // e.g (*1* AND (*2* OR *3*))
    }

    private String addSpecialCharacters(String condition) {
        return '*' + condition.trim() + '*';
    }
}
