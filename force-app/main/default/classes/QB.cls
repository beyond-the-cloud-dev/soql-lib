public inherited sharing class QB implements QB_QueryClause {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public QB(sObjectType ofObject) {
        clauses.set(0, new QB_Fields());
        clauses.set(2, new QB_From(ofObject));
    }

    public QB_Fields fields {
        get {
            return (QB_Fields) clauses[0];
        }
    }

    // 1 - SUB-QUERY

    // 2 - FROM

    public QB_Scope scope {
        get {
            if (clauses[3] == null) {
                clauses.set(3, new QB_Scope());
            }
            return (QB_Scope) clauses[3];
        }
    }

    // 4 - WHERE

    public QB_GroupBy groupBy {
        get {
            if (clauses[6] == null) {
                clauses.set(6, new QB_GroupBy());
            }
            return (QB_GroupBy) clauses[6];
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

    public QB_Limit soqlLimit {
        get {
            if (clauses[8] == null) {
                clauses.set(8, new QB_Limit());
            }
            return (QB_Limit) clauses[8];
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

    public QB_For soqlFor {
        get {
            if (clauses[10] == null) {
                clauses.set(10, new QB_For());
            }
            return (QB_For) clauses[10];
        }
    }

    public String build() {
        List<String> soqlParts = new List<String>();

        for (QB_QueryClause clause : clauses) {
            if (clause == null) {
                continue;
            }
            soqlParts.add(clause.build());
        }

        return String.join(new List<String>(soqlParts), ' ');
    }

    public class QB_Fields implements QB_QueryClause {
        private Set<String> queryFields = new Set<String>{ 'Id' };

        public void retrive(List<sObjectField> fields) {
            for (sObjectField field : fields) {
                queryFields.add(field.getDescribe().getName());
            }
        }

        public void retrive(String relationshipPath, List<sObjectField> fields) {
            for (sObjectField field : fields) {
                queryFields.add(relationshipPath + '.' +field.getDescribe().getName());
            }
        }

        public String build() {
            return 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        }
    }

    public class QB_From implements QB_QueryClause {
        private String objectApiName;

        public QB_From(sObjectType objectType) {
            objectApiName = objectType.getDescribe().getName();
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    public class QB_Scope implements QB_QueryClause {
        private String scope = 'EVERYTHING';

        public void delegated() {
            scope = 'DELEGATED';
        }

        public void mine() {
            scope = 'MINE';
        }

        public void mineAndMyGroups() {
            scope = 'MINE_AND_MY_GROUPS';
        }

        public void myTerritory() {
            scope = 'MY_TERRITORY';
        }

        public void myTeamTerritory() {
            scope = 'MY_TEAM_TERRITORY';
        }

        public void team() {
            scope = 'TEAM';
        }

        public String build() {
            return 'USING SCOPE ' + scope;
        }
    }

    public class QB_GroupBy implements QB_QueryClause {
        private Set<String> groupByFields = new Set<String>();

        public void field(sObjectField field) {
            groupByFields.add(field.getDescribe().getName());
        }

        public void thatHaving() {
            //TODO
        }

        public void rollup() {
            //TODO
        }

        public void cube() {
            //TODO
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
            sortingOrder = 'ASC';
        }

        public void sortDesc() {
            sortingOrder = 'DESC';
        }

        public void nullsFirst() {
            nullsOrder = 'FIRST';
        }

        public void nullsLast() {
            nullsOrder = 'LAST';
        }

        public String build() {
            String orderByStatement = 'ORDER BY ' + String.join(new List<String>(fields), ', ') + ' ' + sortingOrder;

            if (String.isNotEmpty(nullsOrder)) {
                orderByStatement += ' NULLS ' + nullsOrder;
            }

            return orderByStatement;
        }
    }

    public class QB_Limit implements QB_QueryClause {
        private Integer soqlLimit = 50000;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QB_Offset implements QB_QueryClause {
        private Integer soqlOffset = 2000;

        public void fromRow(Integer soqlOffset) {
            this.soqlOffset = soqlOffset;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    public class QB_For implements QB_QueryClause {
        private String forStatement;

        public void forReference() {
            forStatement = 'FOR REFERENCE';
        }

        public void forView() {
            forStatement = 'FOR VIEW';
        }

        public void forUpdate() {
            forStatement = 'FOR UPDATE';
        }

        public void allRows() {
            forStatement = 'ALL ROWS';
        }

        public String build() {
            return forStatement;
        }
    }
}
