public class QB_NullCondition extends QB_Condition {

    public QB_NullCondition(String fieldName) {
        super(fieldName);
    }

    public QB_NullCondition(Schema.SObjectField field) {
        super(field);
    }

    public QB_Condition isNull() {
        this.condition = this.fieldName + ' = NULL';
        return this;
    }

    public QB_Condition isNotNull() {
        this.condition = this.fieldName + ' != NULL';
        return this;
    }
}
