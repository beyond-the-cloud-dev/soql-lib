public class QB_Components {
    public class QFields implements QB_Part {
        private Set<String> queryFields = new Set<String>{ 'Id' };

        public void count() {
            queryFields.add('COUNT(Id)');
        }

        public void count(sObjectField field) {
            queryFields.add('COUNT(' + field.getDescribe().getName() +')');
        }

        public void grouping(sObjectField field) {
            queryFields.add('GROUPING(' + field.getDescribe().getName() +')');
        }

        public void grouping(sObjectField field, String alias) {
            queryFields.add('GROUPING(' + field.getDescribe().getName() +')' + alias);
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
            return 'SELECT ' + String.join(new List<String>(queryFields), ', ');
        }
    }

    public class QB_SubQueries implements QB_Part {
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

        public void thatHaving() {
            //TODO
        }

        public void rollup(sObjectField field) {
            groupByFields.add('ROLLUP(' + field.getDescribe().getName() + ')');
        }

        public void cube(sObjectField field) {
            groupByFields.add('CUBE(' + field.getDescribe().getName() + ')');
        }

        public String build() {
            return 'GROUP BY ' + String.join(new List<String>(groupByFields), ', ');
        }
    }

    public class QOrderBy implements QB_Part {
        private Set<String> fields;
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

        public void grouping(sObjectField field) {
            fields.add('GROUPING(' + field.getDescribe().getName() + ')');
        }

        public void relatedFields(String relationshipPath, List<sObjectField> fields) {
            for (sObjectField field : fields) {
                relatedField(relationshipPath, field);
            }
        }

        public void relatedField(String relationshipPath, sObjectField field) {
            fields.add(relationshipPath + '.' + field.getDescribe().getName());
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