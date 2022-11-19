public class QB_SubQuery extends QB_QueryClause {

    private List<QB> subQueries = new List<QB>();

    public QB_SubQuery(QB subQueryBuilder) {
        this.subQueries.add(subQueryBuilder);
    }

    public QB_SubQuery(List<QB> subQueryBuilders) {
        this.subQueries.addAll(subQueryBuilders);
    }

    public override String build() {
        List<String> subQueriesSoql = new List<String>();

        for (QB qbBuilder : subQueries) {
            subQueriesSoql.add(
                '( \n' + qbBuilder.build() + ')'
            );
        }

        return ',' + String.join(subQueriesSoql, ', ');
    }
}
