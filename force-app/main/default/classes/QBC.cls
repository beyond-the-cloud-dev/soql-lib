public with sharing class QBC {
    public class QFields implements QB_QueryClause {
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

    public class QFrom implements QB_QueryClause {
        private String objectApiName;

        public QFrom(sObjectType objectType) {
            objectApiName = objectType.getDescribe().getName();
        }

        public QFrom(String objectType) {
            objectApiName = objectType;
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    public class QScope implements QB_QueryClause {
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

    public class QGroupBy implements QB_QueryClause {
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

    public class QOrderBy implements QB_QueryClause {
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

    public class QLimit implements QB_QueryClause {
        private Integer soqlLimit = 50000;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QOffset implements QB_QueryClause {
        private Integer soqlOffset = 2000;

        public void fromRow(Integer soqlOffset) {
            this.soqlOffset = soqlOffset;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    public class QFor implements QB_QueryClause {
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
