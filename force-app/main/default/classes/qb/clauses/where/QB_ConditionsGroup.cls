public class QB_ConditionsGroup extends QB_QueryClause {

    private List<QB_Conditions> queryConditions = new List<QB_Conditions>();
    private String conditionOrder = '';

    public QB_ConditionsGroup addCondition(QB_Condition queryCondition) {
        this.addConditions(new QB_Conditions(queryCondition));
        return this;
    }

    public QB_ConditionsGroup addConditions(List<QB_Condition> queryConditions) {
        this.addConditions(new QB_Conditions(queryConditions));
        return this;
    }

    public QB_ConditionsGroup addConditions(List<QB_Condition> queryConditions, String conditionsOrder) {
        this.addConditions(new QB_Conditions(queryConditions).setConditionsOrder(conditionsOrder));
        return this;
    }

    public QB_ConditionsGroup addConditions(QB_Conditions queryConditions) {
        if (queryConditions.hasConditions()) {
            this.queryConditions.add(queryConditions);
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
