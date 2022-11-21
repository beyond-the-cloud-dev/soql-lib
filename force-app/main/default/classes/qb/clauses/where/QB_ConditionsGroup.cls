public class QB_ConditionsGroup extends QB_QueryClause {

    private List<QB_Conditions> queryConditions = new List<QB_Conditions>();
    private String conditionOrder = '';

    public QB_ConditionsGroup addCondition(QB_Condition condition) {
        return this.addConditions(new QB_Conditions(condition));
    }

    public QB_ConditionsGroup addConditions(List<QB_Condition> conditions) {
        return this.addConditions(new QB_Conditions(conditions));
    }

    public QB_ConditionsGroup addConditions(List<QB_Condition> conditions, String conditionsOrder) {
        return this.addConditions(new QB_Conditions(conditions).setConditionsOrder(conditionsOrder));
    }

    public QB_ConditionsGroup addConditions(QB_Conditions qConditions) {
        if (qConditions.hasConditions()) {
            this.queryConditions.add(qConditions);
        }
        return this;
    }

    public override String build() {
        if (this.queryConditions.isEmpty()) {
            return '';
        }

        if (String.isEmpty(this.conditionOrder)) {
            this.conditionOrder = QB_ConditionsUtils.buildDefaultConditionsOrder(this.queryConditions);
        }

        return 'WHERE ' + QB_ConditionsUtils.getConditionsWithFilteringExpressions(this.queryConditions, this.conditionOrder);
    }
}
