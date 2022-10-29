public class QB_ConditionsGroup extends QB_QueryClause {

    private List<QB_Condition> queryConditions = new List<QB_Condition>(); //TODO Should be able to add QB_Condition and QB_Conditions
    private String conditionOrder = '';

    public override String build() {
        if (this.queryConditions.isEmpty()) {
            return '';
        }

        if (String.isEmpty(this.conditionOrder)) {
            this.conditionOrder = '';// TODO Build conditions order
        }

        return 'WHERE ' + '';//TODO Replace nubers with actual values
    }

    public override Integer getPosition() {
        return 5;
    }
}
