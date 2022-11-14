public class QB_BooleanCondition extends QB_Condition {

    public QB_BooleanCondition(String fieldName) {
        super(fieldName);
    }

    public QB_BooleanCondition(Schema.SObjectField field) {
        super(field);
    }

    public QB_Condition equal(Boolean fieldValue) {
        this.condition = this.fieldName + ' = ' + fieldValue;
        return this;
    }

    public QB_Condition notEqual(Boolean fieldValue) {
        this.condition = this.fieldName + ' != ' + fieldValue;
        return this;
    }
}
