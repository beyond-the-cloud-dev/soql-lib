public abstract class QB_Condition extends QB_QueryClause {

    protected String condition;
    protected String fieldName;

    public QB_Condition(String fieldName) {
        this.fieldName = fieldName;
    }

    public QB_Condition(Schema.SObjectField field) {
        this.fieldName = field.getDescribe().getName();
    }

    protected QB_Condition bind(String condition, String nameOfVariableToBind) {
        //e.g bind('IN', 'accountIds');
        this.condition = this.fieldName + ' ' + condition + ' :' + nameOfVariableToBind;
        return this;
    }

    public override String build() {
        return this.condition;
    }
}
