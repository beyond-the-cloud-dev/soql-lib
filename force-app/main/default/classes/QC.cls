public class QC {

    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public QC(sObjectType ofObject) {
        clauses.set(0, new QB_Fields());
        clauses.set(2, new QB_From());
    }

    public QB_Fields fields {
        get {
            return (QB_Fields) clauses[0];
        }
    }

    public QB_Scope scope {
        get {
            if (clauses[3] == null) {
                clauses.set(3, new QB_Scope());
            }
            return (QB_Scope) clauses[3];
        }
    }

    public QB_Offset soqlOffset {
        get {
            if (clauses[9] == null) {
                clauses.set(9, new QB_Offset());
            }
            return (QB_Offset) clauses[9];
        }
    }

    public QB_Limit soqlLimit {
        get {
            if (clauses[10] == null) {
                clauses.set(10, new QB_Limit());
            }
            return (QB_Limit) clauses[10];
        }
    }

    public QB_For soqlFor {
        get {
            if (clauses[10] == null) {
                clauses.set(10, new QB_For());
            }
            return (QB_For) clauses[10];
        }
    }

    public QB_OrderBy orderBy {
        get {
            if (clauses[7] == null) {
                clauses.set(7, new QB_OrderBy());
            }
            return (QB_OrderBy) clauses[7];
        }
    }

    public QB_GroupBy groupBy {
        get {
            if (clauses[7] == null) {
                clauses.set(7, new QB_GroupBy());
            }
            return (QB_GroupBy) clauses[7];
        }
    }

    public class QB_Fields implements QB_QueryClause {
        private Set<String> queryFields = new Set<String>{ 'Id' };

        public QB_Fields retrive(List<sObjectField> fields) {
            for (sObjectField field : fields) {
                queryFields.add(field.getDescribe().getName());
            }
            return this;
        }

        public QB_Fields retrive(String relationshipPath, List<sObjectField> fields) {
            for (sObjectField field : fields) {
                queryFields.add(relationshipPath + '.' +field.getDescribe().getName());
            }
            return this;
        }


        public String build() {
            return 'SELECT ' + String.join(new List<String>(queryFields), ', ');
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

        public QB_Limit max(Integer soqlLimit) {
            soqlLimit = soqlLimit;
            return this;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QB_Offset implements QB_QueryClause {
        private Integer soqlOffset = 2000;

        public QB_Offset fromRow(Integer soqlOffset) {
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

        public void fields(List<sObjectField> fields) {
            for (sObjectField field : fields) {
                field(field);
            }
        }

        public void field(sObjectField field) {
            fields.add(field.getDescribe().getName());
        }

        public void sortAsc() {
            recordsOrder('ASC');
        }

        public void sortDesc() {
            recordsOrder('DESC');
        }

        public void nullsFirst() {
            nullsOrder('FIRST');
        }

        public void nullsLast() {
            nullsOrder('LAST');
        }

        private void recordsOrder(String sortingOrder) {
            sortingOrder = sortingOrder;
        }

        private void nullsOrder(String nullsOrder) {
            nullsOrder = nullsOrder;
        }

        public String build() {
            String orderByStatement = 'ORDER BY ' + String.join(new List<String>(fields), ', ') + ' ' + sortingOrder;

            if (String.isNotEmpty(nullsOrder)) {
                orderByStatement += ' NULLS ' + nullsOrder;
            }

            return orderByStatement;
        }
    }

    // public class QB_Condition implements QB_ConditionClause {
    //     private String fieldName;
    //     private String comperator;

    //     private Object value;
    //     // private QB_Join joinQuery;

    //     public QB_Condition() {
    //         this.fieldName = 'Id';
    //     }

    //     public QB_Condition(String relationshipName, Schema.SObjectField field) {
    //         this.fieldName = relationshipName + '.' + field.getDescribe().getName();
    //     }

    //     public QB_Condition(Schema.SObjectField field) {
    //         this.fieldName = field.getDescribe().getName();
    //     }

    //     public QB_Condition isNull() {
    //         return this.equal(null);
    //     }

    //     public QB_Condition isNotNull() {
    //         return this.notEqual(null);
    //     }

    //     public QB_Condition equal(Object value) {
    //         return this.set('=', value);
    //     }

    //     public QB_Condition notEqual(Object fieldValue) {
    //         return this.set('!=', value);
    //     }

    //     public QB_Condition lessThan(Object value) {
    //         return this.set('<', value);
    //     }

    //     public QB_Condition greaterThan(Object fieldValue) {
    //         return this.set('>', value);
    //     }

    //     public QB_Condition lessThanOrEqual(Object fieldValue) {
    //         return this.set('<=', value);
    //     }

    //     public QB_Condition greaterThanOrEqual(Object fieldValue) {
    //         return this.set('>=', value);
    //     }

    //     public QB_Condition likeAnyBoth(String fieldValue) {
    //         return this.set('LIKE', '%' + String.escapeSingleQuotes(fieldValue.trim()) + '%');
    //     }

    //     public QB_Condition likeAnyLeft(String fieldValue) {
    //         return this.set('LIKE', '%' + String.escapeSingleQuotes(fieldValue.trim()));
    //     }

    //     public QB_Condition likeAnyRight(String fieldValue) {
    //         return this.set('LIKE', String.escapeSingleQuotes(fieldValue.trim()) + '%');
    //     }

    //     public QB_Condition inCollection(List<Object> inList) {
    //         return this.set('IN', inList);
    //     }

    //     public QB_Condition notIn(List<Object> inList) {
    //         return this.set('NOT IN', inList);
    //     }

    //     private QB_Condition set(String comperator, Object value) {
    //         this.value = value;
    //         this.comperator = comperator;
    //         return this;
    //     }

    //     // public QB_Condition inCollection(QB_Join joinQuery) {
    //     //     return this.set('IN', joinQuery);
    //     // }

    //     // public QB_Condition notIn(QB_Join joinQuery) {
    //     //     return this.set('NOT IN', joinQuery);
    //     // }

    //     // private QB_Condition set(String comperator, QB_Join joinQuery) {
    //     //     this.joinQuery = joinQuery;
    //     //     this.comperator = comperator;
    //     //     return this;
    //     // }

    //     public String build() {
    //         // if (this.joinQuery != null) {
    //         //     return this.fieldName + ' ' + this.comperator + ' (' + joinQuery.build(executor) + ')';
    //         //}
    //         return this.fieldName + ' ' + this.comperator + ' :' + executor.bindVariable(this.value);
    //     }
    // }

}
