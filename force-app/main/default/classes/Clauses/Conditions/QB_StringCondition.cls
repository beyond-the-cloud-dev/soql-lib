public class QB_StringCondition extends QB_Condition {

    private final static String QUOTE = '\'';
    private final static String BRACKET_L = '(';
    private final static String BRACKET_R = ')';
    // private final static String INCLUDES = 'INCLUDES';
    // private final static String EXCLUDES = 'EXCLUDES';

    public QB_StringCondition(String fieldName) {
        super(fieldName);
    }

    public QB_StringCondition(Schema.SObjectField field) {
        super(field);
    }

    public QB_Condition bindLike(String nameOfVariableToBind) {
        return this.bind('LIKE', nameOfVariableToBind);
    }

    public QB_Condition likeAnyBoth(String fieldValue) {
        return this.contain('%' + fieldValue + '%');
    }

    public QB_Condition likeAnyLeft(String fieldValue) {
        return this.contain('%' + fieldValue);
    }

    public QB_Condition likeAnyRight(String fieldValue) {
        return this.contain(fieldValue + '%');
    }

    private QB_Condition contain(String fieldValue) {
        this.condition = this.fieldName + ' LIKE ' + this.quote(fieldValue);
        return this;
    }

    private String bracket(String field) {
        return BRACKET_L + field.trim() + BRACKET_R;
    }

    private String quote(String field) {
        return QUOTE + String.escapeSingleQuotes(field.trim()) + QUOTE;
    }
}
