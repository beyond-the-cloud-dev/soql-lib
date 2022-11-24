public class QB_SubQuery extends QB_QueryClause {

    private List<QB> subQueries = new List<QB>();

    public QB_SubQuery add(QB subQueryBuilder) {
        this.subQueries.add(subQueryBuilder);
        return this;
    }

    public QB_SubQuery add(List<QB> subQueryBuilders) {
        this.subQueries.addAll(subQueryBuilders);
        return this;
    }

    public override String build() {
        List<String> subQueriesSoql = new List<String>();

        for (QB qbBuilder : subQueries) {
            subQueriesSoql.add(
                '(' + qbBuilder.build() + ')'
            );
        }

        return ', ' + String.join(subQueriesSoql, ', ');
    }
}
