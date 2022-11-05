public class QB_SubQuery extends QB_QueryClause {

    private List<QB_QueryBuilder> subQueries = new List<QB_QueryBuilder>();

    public QB_SubQuery(QB_QueryBuilder subQueryBuilder) {
        this.subQueries.add(subQueryBuilder);
    }

    public QB_SubQuery(List<QB_QueryBuilder> subQueryBuilders) {
        this.subQueries.addAll(subQueryBuilders);
    }

    public override String build() {
        List<String> subQueriesSoql = new List<String>();

        for (QB_QueryBuilder qbBuilder : subQueries) {
            subQueriesSoql.add(
                '( \n' + qbBuilder.build() + ')'
            );
        }

        return ',' + String.join(subQueriesSoql, ', ');
    }

    public override Integer getPosition() {
        return 2;
    }
}
