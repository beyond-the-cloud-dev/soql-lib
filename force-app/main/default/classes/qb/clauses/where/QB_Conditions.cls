public class QB_Conditions extends QB_QueryClause {

    private List<QB_Condition> queryConditions = new List<QB_Condition>();
    private String conditionOrder = '';

    public QB_Conditions(QB_Condition queryCondition) {
        this.add(queryCondition);
    }

    public QB_Conditions(List<QB_Condition> queryConditions) {
        this.add(queryConditions);
    }

    public QB_Conditions add(QB_Condition queryCondition) {
        this.queryConditions.add(queryCondition);
        return this;
    }

    public QB_Conditions add(List<QB_Condition> queryConditions) {
        this.queryConditions.addAll(queryConditions);
        return this;
    }

    public QB_Conditions setConditionsOrder(String conditionsOrder) {
        this.conditionOrder = conditionsOrder;
        return this;
    }

    public override String build() {
        if (this.queryConditions.isEmpty()) {
            return '';
        }

        if (String.isEmpty(this.conditionOrder)) {
            this.conditionOrder = QB_ConditionsUtils.buildDefaultConditionsOrder(this.queryConditions);
        }

        return QB_ConditionsUtils.getConditionsWithFilteringExpressions(this.queryConditions, this.conditionOrder);
    }

    public override String validate() {
        if (String.isEmpty(this.conditionOrder)) {
            return '';
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

        return errors;
    }

    public Boolean hasConditions() {
        return !this.queryConditions.isEmpty();
    }
}
