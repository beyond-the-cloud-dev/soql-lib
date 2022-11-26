public with sharing class QB_SubQueries extends QB_QueryClause {
    private List<QB_SubQuery> subQueries = new List<QB_SubQuery>();

    public QB_SubQueries add(QB_SubQuery subQueryBuilder) {
        this.subQueries.add(subQueryBuilder);
        return this;
    }

    public override String build() {
        List<String> subQueriesSoql = new List<String>();

        for (QB_SubQuery qbBuilder : subQueries) {
            subQueriesSoql.add(
                '(' + qbBuilder.build() + ')'
            );
        }

        return ', ' + String.join(subQueriesSoql, ', ');
    }
}
