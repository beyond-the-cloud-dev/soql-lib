public abstract class QB_Condition extends QB_QueryClause {
    public String fieldName;
    private String condition;

    public QB_Condition(String fieldName) {
        this.fieldName = fieldName;
    }

    public QB_Condition(Schema.SObjectField field) {
        this.fieldName = field.getDescribe().getName();
    }

    public void equal(Boolean fieldValue) {
        this.condition = new QB_BooleanCondition().equal(fieldValue);
    }

    public void notEqual(Boolean fieldValue) {
        this.condition = new QB_BooleanCondition().notEqual(fieldValue);
    }

    public void isNull() {
        this.condition = new QB_NullCondition().isNull();
    }

    public void isNotNull() {
        this.condition = new QB_NullCondition().isNotNull();
    }

    public void equal(Decimal fieldValue) {
        this.condition = new QB_NumberCondition().equal(fieldValue);
    }

    public void lessThan(Decimal fieldValue) {
        this.condition = new QB_NumberCondition().lessThan(fieldValue);
    }

    public void greaterThan(Decimal fieldValue) {
        this.condition = new QB_NumberCondition().greaterThan(fieldValue);
    }

    public void lessThanOrEqual(Decimal fieldValue) {
        this.condition = new QB_NumberCondition().lessThanOrEqual(fieldValue);
    }

    public void greaterThanOrEqual(Decimal fieldValue) {
        this.condition = new QB_NumberCondition().greaterThanOrEqual(fieldValue);
    }

    public void notEqual(Decimal fieldValue) {
        this.condition = new QB_NumberCondition().notEqual(fieldValue);
    }

    public void lessThan(String fieldValue) {
        this.condition = new QB_DateCondition().lessThan(fieldValue);
    }

    public void greaterThan(String fieldValue) {
        this.condition = new QB_DateCondition().greaterThan(fieldValue);
    }

    public void lessThanOrEqual(String fieldValue) {
        this.condition = new QB_DateCondition().lessThanOrEqual(fieldValue);
    }

    public void greaterThanOrEqual(String fieldValue) {
        this.condition = new QB_DateCondition().greaterThanOrEqual(fieldValue);
    }

    public override String build() {
        return this.fieldName + this.condition;
    }

    private class QB_BooleanCondition {
        public String equal(Boolean fieldValue) {
            return ' = ' + fieldValue;
        }

        public String notEqual(Boolean fieldValue) {
            return ' != ' + fieldValue;
        }
    }

    private class QB_NullCondition {
        public String isNull() {
            return ' = NULL';
        }

        public String isNotNull() {
            return ' != NULL';
        }
    }

    private class QB_NumberCondition {
        public String equal(Decimal fieldValue) {
            return ' = ' + fieldValue;
        }

        public String lessThan(Decimal fieldValue) {
            return ' < ' + fieldValue;
        }

        public String greaterThan(Decimal fieldValue) {
            return ' > ' + fieldValue;
        }

        public String lessThanOrEqual(Decimal fieldValue) {
            return ' <= ' + fieldValue;
        }

        public String greaterThanOrEqual(Decimal fieldValue) {
            return ' >= ' + fieldValue;
        }

        public String notEqual(Decimal fieldValue) {
            return ' != ' + fieldValue;
        }
    }

    private class QB_DateCondition {
        // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_dateformats.htm

        public String lessThan(String fieldValue) {
            return ' < ' + fieldValue;
        }

        public String greaterThan(String fieldValue) {
            return ' > ' + fieldValue;
        }

        public String lessThanOrEqual(String fieldValue) {
            return ' <= ' + fieldValue;
        }

        public String greaterThanOrEqual(String fieldValue) {
            return ' >= ' + fieldValue;
        }
    }
}
