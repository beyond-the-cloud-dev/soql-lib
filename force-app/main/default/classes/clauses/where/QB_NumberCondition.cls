public class QB_NumberCondition extends QB_Condition {

    public QB_NumberCondition(String fieldName) {
        super(fieldName);
    }

    public QB_NumberCondition(Schema.SObjectField field) {
        super(field);
    }

    public QB_Condition equal(Decimal fieldValue) {
        this.condition = this.fieldName + ' = ' + fieldValue;
        return this;
    }

    public QB_Condition lessThan(Decimal fieldValue) {
        this.condition = this.fieldName + ' < ' + fieldValue;
        return this;
    }

    public QB_Condition greaterThan(Decimal fieldValue) {
        this.condition = this.fieldName + ' > ' + fieldValue;
        return this;
    }

    public QB_Condition lessThanOrEqual(Decimal fieldValue) {
        this.condition = this.fieldName + ' <= ' + fieldValue;
        return this;
    }

    public QB_Condition greaterThanOrEqual(Decimal fieldValue) {
        this.condition = this.fieldName + ' >= ' + fieldValue;
        return this;
    }

    public QB_Condition notEqual(Decimal fieldValue) {
        this.condition = this.fieldName + ' != ' + fieldValue;
        return this;
    }
}
