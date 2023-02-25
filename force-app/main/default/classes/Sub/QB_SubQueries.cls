public with sharing class QB_SubQueries implements QB_QueryClause {
    private List<QB_Sub> subQueries = new List<QB_Sub>();

    public QB_SubQueries add(QB_Sub subQueryBuilder) {
        subQueries.add(subQueryBuilder);
        return this;
    }

    public String build() {
        List<String> subQueriesSoql = new List<String>();

        for (QB_Sub qbBuilder : subQueries) {
            subQueriesSoql.add(
                '(' + qbBuilder.build() + ')'
            );
        }

        return ', ' + String.join(subQueriesSoql, ', ');
    }
}
