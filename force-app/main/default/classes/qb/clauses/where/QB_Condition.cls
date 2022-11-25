public class QB_Condition extends QB_ConditionClause {
    public String fieldName;
    private String condition;

    public QB_Condition(String relationshipName, Schema.SObjectField field) {
        this.fieldName = relationshipName + '.' + field.getDescribe().getName();
    }

    public QB_Condition(Schema.SObjectField field) {
        this.fieldName = field.getDescribe().getName();
    }

    public QB_Condition equal(Boolean fieldValue) {
        return this.setCondition(new QB_BooleanCondition().equal(fieldValue));
    }

    public QB_Condition notEqual(Boolean fieldValue) {
        return this.setCondition(new QB_BooleanCondition().notEqual(fieldValue));
    }

    public QB_Condition isNull() {
        return this.setCondition(new QB_NullCondition().isNull());
    }

    public QB_Condition isNotNull() {
        return this.setCondition(new QB_NullCondition().isNotNull());
    }

    public QB_Condition equal(Decimal fieldValue) {
        return this.setCondition(new QB_NumberCondition().equal(fieldValue));
    }

    public QB_Condition lessThan(Decimal fieldValue) {
        return this.setCondition(new QB_NumberCondition().lessThan(fieldValue));
    }

    public QB_Condition greaterThan(Decimal fieldValue) {
        return this.setCondition(new QB_NumberCondition().greaterThan(fieldValue));
    }

    public QB_Condition lessThanOrEqual(Decimal fieldValue) {
        return this.setCondition(new QB_NumberCondition().lessThanOrEqual(fieldValue));
    }

    public QB_Condition greaterThanOrEqual(Decimal fieldValue) {
        return this.setCondition(new QB_NumberCondition().greaterThanOrEqual(fieldValue));
    }

    public QB_Condition notEqual(Decimal fieldValue) {
        return this.setCondition(new QB_NumberCondition().notEqual(fieldValue));
    }

    public QB_Condition lessThan(String fieldValue) {
        return this.setCondition(new QB_DateCondition().lessThan(fieldValue));
    }

    public QB_Condition greaterThan(String fieldValue) {
        return this.setCondition(new QB_DateCondition().greaterThan(fieldValue));
    }

    public QB_Condition lessThanOrEqual(String fieldValue) {
        return this.setCondition(new QB_DateCondition().lessThanOrEqual(fieldValue));
    }

    public QB_Condition greaterThanOrEqual(String fieldValue) {
        return this.setCondition(new QB_DateCondition().greaterThanOrEqual(fieldValue));
    }

    public QB_Condition bindLike(String nameOfVariableToBind) {
        return this.setCondition(new QB_StringCondition().bindLike(nameOfVariableToBind));
    }

    public QB_Condition equal(String fieldValue) {
        return this.setCondition(new QB_StringCondition().equal(fieldValue));
    }

    public QB_Condition notEqual(String fieldValue) {
        return this.setCondition(new QB_StringCondition().notEqual(fieldValue));
    }

    public QB_Condition likeAnyBoth(String fieldValue) {
        return this.setCondition(new QB_StringCondition().likeAnyBoth(fieldValue));
    }

    public QB_Condition likeAnyLeft(String fieldValue) {
        return this.setCondition(new QB_StringCondition().likeAnyLeft(fieldValue));
    }

    public QB_Condition likeAnyRight(String fieldValue) {
        return this.setCondition(new QB_StringCondition().likeAnyRight(fieldValue));
    }

    public QB_Condition contain(String fieldValue) {
        return this.setCondition(new QB_StringCondition().contain(fieldValue));
    }

    public QB_Condition inCollection(List<String> inList) {
        return this.setCondition(new QB_CollectionCondition().inCollection(inList));
    }

    public QB_Condition inCollection(List<Decimal> inList) {
        return this.setCondition(new QB_CollectionCondition().inCollection(inList));
    }

    public QB_Condition notIn(List<String> inList) {
        return this.setCondition(new QB_CollectionCondition().notIn(inList));
    }

    public QB_Condition bindInCollection(String nameOfVariableToBind) {
        return this.setCondition(new QB_CollectionCondition().bindInCollection(nameOfVariableToBind));
    }

    public QB_Condition bindNotInCollection(String nameOfVariableToBind) {
        return this.setCondition(new QB_CollectionCondition().bindNotInCollection(nameOfVariableToBind));
    }

    private QB_Condition setCondition(String condition) {
        this.condition = condition;
        return this;
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

        public String bindLike(String nameOfVariableToBind) {
            return this.bind('LIKE', nameOfVariableToBind);
        }

        public String equal(String fieldValue) {
            return ' = ' +  this.quote(fieldValue);
        }

        public String notEqual(String fieldValue) {
            return ' != ' +  this.quote(fieldValue);
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
