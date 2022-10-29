public abstract class QB_Condition extends QB_QueryClause {

    protected String condition;
    protected String fieldName;

    public QB_Condition(String fieldName) {
        this.fieldName = fieldName;
    }

    public QB_Condition(Schema.SObjectField field) {
        this.fieldName = field.getDescribe().getName();
    }

    public override String build() {
        return this.condition;
    }

    public override Integer getPosition() {
        return null;
    }
}
