public class QB_ConditionsGroup extends QB_QueryClause {
    private List<QB_Conditions> queryConditions = new List<QB_Conditions>();
    private String conditionOrder = '';

    public QB_ConditionsGroup add(QB_Condition condition) {
        return this.add(new QB_Conditions().add(condition));
    }

    public QB_ConditionsGroup add(List<QB_Condition> conditions) {
        return this.add(new QB_Conditions().add(conditions));
    }

    public QB_ConditionsGroup add(List<QB_Condition> conditions, String conditionsOrder) {
        return this.add(new QB_Conditions().add(conditions).setConditionsOrder(conditionsOrder));
    }

    public QB_ConditionsGroup add(QB_Conditions qConditions) {
        if (qConditions.hasConditions()) {
            this.queryConditions.add(qConditions);
        }
        return this;
    }

    public QB_ConditionsGroup setConditionsOrder(String conditionsOrder) {
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

        return 'WHERE ' + QB_ConditionsUtils.getConditionsWithFilteringExpressions(this.queryConditions, this.conditionOrder);
    }
}
