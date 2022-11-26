public with sharing class QB_SubQueries extends QB_QueryClause {
    private List<QB_Sub> subQueries = new List<QB_Sub>();

    public QB_SubQueries add(QB_Sub subQueryBuilder) {
        this.subQueries.add(subQueryBuilder);
        return this;
    }

    public override String build() {
        List<String> subQueriesSoql = new List<String>();

        for (QB_Sub qbBuilder : subQueries) {
            subQueriesSoql.add(
                '(' + qbBuilder.build() + ')'
            );
        }

        return ', ' + String.join(subQueriesSoql, ', ');
    }
}
