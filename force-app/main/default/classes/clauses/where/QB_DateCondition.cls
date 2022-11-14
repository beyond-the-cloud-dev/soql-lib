public class QB_DateCondition extends QB_Condition {

    // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_dateformats.htm

    public QB_DateCondition(String fieldName) {
        super(fieldName);
    }

    public QB_DateCondition(Schema.SObjectField field) {
        super(field);
    }

    public QB_Condition lessThan(String fieldValue) {
        this.condition = this.fieldName + ' < ' + fieldValue;
        return this;
    }

    public QB_Condition greaterThan(String fieldValue) {
        this.condition = this.fieldName + ' > ' + fieldValue;
        return this;
    }

    public QB_Condition lessThanOrEqual(String fieldValue) {
        this.condition = this.fieldName + ' <= ' + fieldValue;
        return this;
    }

    public QB_Condition greaterThanOrEqual(String fieldValue) {
        this.condition = this.fieldName + ' >= ' + fieldValue;
        return this;
    }
}
