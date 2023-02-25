public with sharing class QB_SubQueries implements QB_QueryClause {
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
