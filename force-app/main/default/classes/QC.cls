public class QC {

    public static QB_Fields Fields {
        get {
            return new QB_Fields();
        }
    }

    public static QB_From QFrom {
        get {
            return new QB_From();
        }
    }

    public static QB_Limit QLimit {
        get {
            return new QB_Limit();
        }
    }

    public static QB_For QFor {
        get {
            return new QB_For();
        }
    }

    public static QB_Scope Scope {
        get {
            return new QB_Scope();
        }
    }

    public static QB_Offset QOffset {
        get {
            return new QB_Offset();
        }
    }

    public static QB_GroupBy GroupBy {
        get {
            return new QB_GroupBy();
        }
    }

    public static QB_OrderBy OrderBy {
        get {
            return new QB_OrderBy();
        }
    }

    public class QB_Fields implements QB_QueryClause {
        private Set<String> fields = new Set<String>{ 'Id' };

        public QB_Fields get(sObjectField field) {
            fields.add(field.getDescribe().getName());
            return this;
        }

        public String build() {
            return 'SELECT ' + String.join(new List<String>(fields), ', ');
        }
    }

    public class QB_From implements QB_QueryClause {
        private String objectApiName;

        public QB_From of(sObjectType objectType) {
            objectApiName = objectType.getDescribe().getName();
            return this;
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    public class QB_Limit implements QB_QueryClause {
        private Integer soqlLimit = 50000;

        public QB_Limit set(Integer soqlLimit) {
            soqlLimit = soqlLimit;
            return this;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QB_Offset implements QB_QueryClause {
        private Integer soqlOffset = 2000;

        public QB_Offset set(Integer soqlOffset) {
            soqlOffset = soqlOffset;
            return this;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    public class QB_Scope implements QB_QueryClause {
        private String scope = 'EVERYTHING';

        public QB_Scope delegated() {
            return scope('DELEGATED');
        }

        public QB_Scope mine() {
            return scope('MINE');
        }

        public QB_Scope mineAndMyGroups() {
            return scope('MINE_AND_MY_GROUPS');
        }

        public QB_Scope myTerritory() {
            return scope('MY_TERRITORY');
        }

        public QB_Scope myTeamTerritory() {
            return scope('MY_TEAM_TERRITORY');
        }

        public QB_Scope team() {
            return scope('TEAM');
        }

        private QB_Scope scope(String scope) {
            scope = scope;
            return this;
        }

        public String build() {
            return 'USING SCOPE ' + scope;
        }
    }

    public class QB_For implements QB_QueryClause {
        private String forStatement = 'ALL ROWS';

        public QB_For forReference() {
            return forStatement('FOR REFERENCE');
        }

        public QB_For forView() {
            return forStatement('FOR VIEW');
        }

        public QB_For forUpdate() {
            return forStatement('FOR UPDATE');
        }

        public QB_For allRows() {
            return forStatement('ALL ROWS');
        }

        private QB_For forStatement(String forStatement) {
            forStatement = forStatement;
            return this;
        }

        public String build() {
            return forStatement;
        }
    }

    public class QB_GroupBy implements QB_QueryClause {
        private Set<String> groupByFields = new Set<String>();

        public QB_GroupBy field(sObjectField field) {
            groupByFields.add(field.getDescribe().getName());
            return this;
        }

        public QB_GroupBy thatHaving() {
            return this;
        }

        public QB_GroupBy rollup() {
            return this;
        }

        public QB_GroupBy cube() {
            return this;
        }

        public String build() {
            return 'GROUP BY ' + String.join(new List<String>(groupByFields), ', ');
        }
    }

    public class QB_OrderBy implements QB_QueryClause {
        private List<String> fields;
        private String sortingOrder = 'ASC';
        private String nullsOrder;

        public QB_OrderBy field(sObjectField field) {
            return field(field.getDescribe().getName());
        }

        public QB_OrderBy field(String field) {
            fields.add(field);
            return this;
        }

        public QB_OrderBy sortAsc() {
            return recordsOrder('ASC');
        }

        public QB_OrderBy sortDesc() {
            return recordsOrder('DESC');
        }

        public QB_OrderBy nullsFirst() {
            return nullsOrder('FIRST');
        }

        public QB_OrderBy nullsLast() {
            return nullsOrder('LAST');
        }

        private QB_OrderBy recordsOrder(String sortingOrder) {
            sortingOrder = sortingOrder;
            return this;
        }

        private QB_OrderBy nullsOrder(String nullsOrder) {
            nullsOrder = nullsOrder;
            return this;
        }

        public String build() {
            String orderByStatement = 'ORDER BY ' + String.join(new List<String>(fields), ', ') + ' ' + sortingOrder;

            if (String.isNotEmpty(nullsOrder)) {
                orderByStatement += ' NULLS ' + nullsOrder;
            }

            return orderByStatement;
        }
    }

    public class QB_Condition implements QB_ConditionClause {
        private String fieldName;
        private String comperator;

        private Object value;
        private QB_Join joinQuery;

        public QB_Condition() {
            this.fieldName = 'Id';
        }

        public QB_Condition(String relationshipName, Schema.SObjectField field) {
            this.fieldName = relationshipName + '.' + field.getDescribe().getName();
        }

        public QB_Condition(Schema.SObjectField field) {
            this.fieldName = field.getDescribe().getName();
        }

        public QB_Condition isNull() {
            return this.equal(null);
        }

        public QB_Condition isNotNull() {
            return this.notEqual(null);
        }

        public QB_Condition equal(Object value) {
            return this.set('=', value);
        }

        public QB_Condition notEqual(Object fieldValue) {
            return this.set('!=', value);
        }

        public QB_Condition lessThan(Object value) {
            return this.set('<', value);
        }

        public QB_Condition greaterThan(Object fieldValue) {
            return this.set('>', value);
        }

        public QB_Condition lessThanOrEqual(Object fieldValue) {
            return this.set('<=', value);
        }

        public QB_Condition greaterThanOrEqual(Object fieldValue) {
            return this.set('>=', value);
        }

        public QB_Condition likeAnyBoth(String fieldValue) {
            return this.set('LIKE', '%' + String.escapeSingleQuotes(fieldValue.trim()) + '%');
        }

        public QB_Condition likeAnyLeft(String fieldValue) {
            return this.set('LIKE', '%' + String.escapeSingleQuotes(fieldValue.trim()));
        }

        public QB_Condition likeAnyRight(String fieldValue) {
            return this.set('LIKE', String.escapeSingleQuotes(fieldValue.trim()) + '%');
        }

        public QB_Condition inCollection(List<Object> inList) {
            return this.set('IN', inList);
        }

        public QB_Condition notIn(List<Object> inList) {
            return this.set('NOT IN', inList);
        }

        private QB_Condition set(String comperator, Object value) {
            this.value = value;
            this.comperator = comperator;
            return this;
        }

        public QB_Condition inCollection(QB_Join joinQuery) {
            return this.set('IN', joinQuery);
        }

        public QB_Condition notIn(QB_Join joinQuery) {
            return this.set('NOT IN', joinQuery);
        }

        private QB_Condition set(String comperator, QB_Join joinQuery) {
            this.joinQuery = joinQuery;
            this.comperator = comperator;
            return this;
        }

        public String build(QB_QueryExecutor executor) {
            if (this.joinQuery != null) {
                return this.fieldName + ' ' + this.comperator + ' (' + joinQuery.build(executor) + ')';
            }
            return this.fieldName + ' ' + this.comperator + ' :' + executor.bindVariable(this.value);
        }
    }

}
