public class QB_StringCondition extends QB_Condition {

    public QB_StringCondition(String fieldName) {
        super(fieldName);
    }

    public QB_StringCondition(Schema.SObjectField field) {
        super(field);
    }

    public QB_Condition equal(String fieldValue) {
        this.condition = this.fieldName + ' = ' + fieldValue;
        return this;
    }

    public QB_Condition notEqual(String fieldValue) {
        this.condition = this.fieldName + ' != ' + fieldValue;
        return this;
    }
}
