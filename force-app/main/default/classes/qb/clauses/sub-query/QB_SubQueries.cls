public with sharing class QB_SubQueries implements QB_QueryClause {
    private List<QB_Sub> subQueries = new List<QB_Sub>();

    public QB_SubQueries add(QB_Sub subQueryBuilder) {
        this.subQueries.add(subQueryBuilder);
        return this;
    }

    public String build(QB_QueryExecutor executor) {
        List<String> subQueriesSoql = new List<String>();

        for (QB_Sub qbBuilder : subQueries) {
            subQueriesSoql.add(
                '(' + qbBuilder.build(executor) + ')'
            );
        }

        return ', ' + String.join(subQueriesSoql, ', ');
    }
}
