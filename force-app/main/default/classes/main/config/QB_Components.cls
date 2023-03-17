public class QB_Components {
    public class QFields implements QB_Part {
        private Set<String> queryFields = new Set<String>();

        public void count() {
            queryFields.add('COUNT()');
        }

        public void count(sObjectField field, String alias) {
            queryFields.add('COUNT(' + field.getDescribe().getName() +') ' + alias);
        }

        public void retrive(List<sObjectField> fields) {
            for (sObjectField field : fields) {
                retrive(field);
            }
        }

        public void retrive(sObjectField field) {
            queryFields.add(field.getDescribe().getName());
        }

        public void retrive(String relationshipPath, List<sObjectField> fields) {
            for (sObjectField field : fields) {
                retrive(relationshipPath, field);
            }
        }

        public void retrive(String relationshipPath, sObjectField field) {
            queryFields.add(relationshipPath + '.' + field.getDescribe().getName());
        }

        public String build() {
            if (queryFields.isEmpty()) {
                return 'SELECT Id';
            }
            return 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        }
    }

    public class QSubQueries implements QB_Part {
        private List<QB_Sub> subQueries = new List<QB_Sub>();

        public void add(QB_Sub subQuery) {
            subQueries.add(subQuery);
        }

        public String build() {
            List<String> subQueriesSoql = new List<String>();

            for (QB_Sub sub : subQueries) {
                subQueriesSoql.add('(' + sub.build() + ')');
            }

            return ', ' + String.join(subQueriesSoql, ', ');
        }
    }

    public class QFrom implements QB_Part {
        private String objectApiName;

        public QFrom(String objectType) {
            objectApiName = objectType;
        }

        public String build() {
            return 'FROM ' + objectApiName;
        }
    }

    public class QScope implements QB_Part {
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

    public class QGroupBy implements QB_Part {
        private Set<String> groupByFields = new Set<String>();

        public void field(sObjectField field) {
            groupByFields.add(field.getDescribe().getName());
        }

        public void rollup(sObjectField field) {
            groupByFields.add('ROLLUP(' + field.getDescribe().getName() + ')');
        }

        public String build() {
            return 'GROUP BY ' + String.join(new List<String>(groupByFields), ', ');
        }
    }

    public class QOrderBys implements QB_Part {
        public List<QOrderBy> orderBys = new List<QOrderBy>();

        public void add(sObjectField field) {
            orderBys.add(new QOrderBy().field(field));
        }

        public void add(String relationshipPath, sObjectField field) {
            orderBys.add(new QOrderBy().relatedField(relationshipPath, field));
        }

        public QOrderBy recentOrderBy() {
            return orderBys.get(orderBys.size() - 1);
        }

        public String build() {
            List<String> orderFields = new List<String>();

            for (QOrderBy orderBy : orderBys) {
                orderFields.add(orderBy.build());
            }

            return 'ORDER BY ' + String.join(orderFields, ', ');
        }
    }

    public class QOrderBy implements QB_Part {
        private String orderField;
        private String sortingOrder = 'ASC';
        private String nullsOrder = 'FIRST';

        public QOrderBy field(sObjectField field) {
            orderField = field.getDescribe().getName();
            return this;
        }

        public QOrderBy relatedField(String relationshipPath, sObjectField field) {
            orderField = relationshipPath + '.' + field.getDescribe().getName();
            return this;
        }

        public void sortDesc() {
            sortingOrder = 'DESC';
        }

        public void nullsLast() {
            nullsOrder = 'LAST';
        }

        public String build() {
            return orderField + ' ' + sortingOrder + ' NULLS ' + nullsOrder;
        }
    }

    public class QLimit implements QB_Part {
        private Integer soqlLimit = 50000;

        public void max(Integer soqlLimit) {
            this.soqlLimit = soqlLimit;
        }

        public String build() {
            return 'LIMIT ' + this.soqlLimit;
        }
    }

    public class QOffset implements QB_Part {
        private Integer soqlOffset = 2000;

        public void fromRow(Integer soqlOffset) {
            this.soqlOffset = soqlOffset;
        }

        public String build() {
            return 'OFFSET ' + soqlOffset;
        }
    }

    public class QFor implements QB_Part {
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
