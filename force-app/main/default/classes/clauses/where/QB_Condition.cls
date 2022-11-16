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

    public void likeAnyBoth(String fieldValue) {
        this.condition = new QB_StringCondition().likeAnyBoth(fieldValue);
    }

    public void likeAnyLeft(String fieldValue) {
        this.condition = new QB_StringCondition().likeAnyLeft(fieldValue);
    }

    public void likeAnyRight(String fieldValue) {
        this.condition = new QB_StringCondition().likeAnyRight(fieldValue);
    }

    public void contain(String fieldValue) {
        this.condition = new QB_StringCondition().contain(fieldValue);
    }

    public void inCollection(List<String> inList) {
        this.condition = new QB_CollectionCondition().inCollection(inList);
    }

    public void inCollection(List<Decimal> inList) {
        this.condition = new QB_CollectionCondition().inCollection(inList);
    }

    public void notIn(List<String> inList) {
        this.condition = new QB_CollectionCondition().notIn(inList);
    }

    public void bindInCollection(String nameOfVariableToBind) {
        this.condition = new QB_CollectionCondition().bindInCollection(nameOfVariableToBind);
    }

    public void bindNotInCollection(String nameOfVariableToBind) {
        this.condition = new QB_CollectionCondition().bindNotInCollection(nameOfVariableToBind);
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

    private class QB_StringCondition {
        private final String QUOTE = '\'';
        private final String BRACKET_L = '(';
        private final String BRACKET_R = ')';

        public String bindLike(String nameOfVariableToBind) {
            return this.bind('LIKE', nameOfVariableToBind);
        }

        public String likeAnyBoth(String fieldValue) {
            return this.contain('%' + fieldValue + '%');
        }

        public String likeAnyLeft(String fieldValue) {
            return this.contain('%' + fieldValue);
        }

        public String likeAnyRight(String fieldValue) {
            return this.contain(fieldValue + '%');
        }

        private String contain(String fieldValue) {
            return ' LIKE ' + this.quote(fieldValue);
        }

        private String bind(String condition, String nameOfVariableToBind) {
            //e.g bind('LIKE', 'accountIds');
            return ' ' + condition + ' :' + nameOfVariableToBind;
        }

        private String quote(String field) {
            return QUOTE + String.escapeSingleQuotes(field.trim()) + QUOTE;
        }
    }

    private class QB_CollectionCondition {
        private final String QUOTE = '\'';
        private final String BRACKET_L = '(';
        private final String BRACKET_R = ')';

        public String inCollection(List<String> inList) {
            if (inList.isEmpty()) {
                return '';
            }
            return ' IN ' + this.buildIn(inList);
        }

        public String inCollection(List<Decimal> inList) {
            if (inList.isEmpty()) {
                return '';
            }

            return ' IN ' + this.buildInNoQuote(inList);
        }

        public String notIn(List<String> inList) {
            if (inList.isEmpty()) {
                return '';
            }

            return ' NOT IN ' + this.buildIn(inList);
        }

        // binding

        public String bindInCollection(String nameOfVariableToBind) {
            return this.bind('IN', nameOfVariableToBind);
        }

        public String bindNotInCollection(String nameOfVariableToBind) {
            return this.bind('NOT IN', nameOfVariableToBind);
        }

        private String bind(String condition, String nameOfVariableToBind) {
            //e.g bind('IN', 'accountIds');
            return ' ' + condition + ' :' + nameOfVariableToBind;
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
}
