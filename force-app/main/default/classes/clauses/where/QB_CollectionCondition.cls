public class QB_CollectionCondition extends QB_Condition {

    private final static String QUOTE = '\'';
    private final static String BRACKET_L = '(';
    private final static String BRACKET_R = ')';

    public QB_CollectionCondition(String fieldName) {
        super(fieldName);
    }

    public QB_CollectionCondition(Schema.SObjectField field) {
        super(field);
    }

    // binding

    public QB_Condition bindInCollection(String nameOfVariableToBind) {
        return this.bind('IN', nameOfVariableToBind);
    }

    public QB_Condition bindNotInCollection(String nameOfVariableToBind) {
        return this.bind('NOT IN', nameOfVariableToBind);
    }

    public QB_Condition inCollection(List<String> inList) {
        if (inList.isEmpty()) {
            this.condition = '';
        }
        this.condition = this.fieldName + ' IN ' + this.buildIn(inList);
        return this;
    }

    public QB_Condition inCollection(List<Decimal> inList) {
        if (inList.isEmpty()) { //TODO Check how empty condition should looks like
            this.condition = '';
        }

        this.condition = this.fieldName + ' IN ' + this.buildInNoQuote(inList);
        return this;
    }

    public QB_Condition notIn(List<String> inList) {
        if (inList.isEmpty()) {
            this.condition = '';
            return this;
        }

        this.condition = this.fieldName + ' NOT IN ' + this.buildIn(inList);
        return this;
    }

    private String buildIn(List<String> inList) {
        return this.bracket(QUOTE + String.join(inList, QUOTE + ', ' + QUOTE) + QUOTE);
    }

    private String buildInNoQuote(List<Decimal> inList) {
        return this.bracket(String.join(inList, ', '));
    }

    private String bracket(String field) {
        return BRACKET_L + field.trim() + BRACKET_R;
    }
}
