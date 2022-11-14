public abstract class QB_Condition extends QB_QueryClause {

    private QB_Cond cond;

    public QB_Condition(String fieldName) {
        this.fieldName = fieldName;
    }

    public QB_Condition(Schema.SObjectField field) {
        this.fieldName = field.getDescribe().getName();
    }


    // protected QB_Condition bind(String condition, String nameOfVariableToBind) {
    //     //e.g bind('IN', 'accountIds');
    //     this.condition = this.fieldName + ' ' + condition + ' :' + nameOfVariableToBind;
    //     return this;
    // }

    public void equal(Boolean fieldValue) {
        cond = new QB_BooleanCondition().equal(fieldValue);
    }

    public void notEqual(Boolean fieldValue) {
        cond = new QB_BooleanCondition().notEqual(fieldValue);
    }

    public override String build() {
        return cond.build();
    }

    public abstract class QB_Cond extends QB_QueryClause {
        protected String condition;


        public override String build() {
            return this.condition;
        }
    }

    public class QB_BooleanCondition extends QB_Cond {
        public QB_BooleanCondition equal(Boolean fieldValue) {
            this.condition = this.fieldName + ' = ' + fieldValue;
            return this;
        }

        public QB_BooleanCondition notEqual(Boolean fieldValue) {
            this.condition = this.fieldName + ' != ' + fieldValue;
            return this;
        }
    }
}
