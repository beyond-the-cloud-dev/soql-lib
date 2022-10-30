public class QB_QueryBuilder extends QB_QueryClause {

    protected Set<QB_QueryClause> queryClauses;

    public QB_QueryBuilder(sObjectType objectType) {
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(objectType) };
    }

    public QB_QueryBuilder(String fromObject) { // for subQuery
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(fromObject) };
    }

    public override String build() {
        List<QB_QueryClause> queryClausesToProcess = new List<QB_QueryClause>(queryClauses);

        queryClausesToProcess.sort(); //sort by getPosition

        List<String> clauses = new List<String>();

        for (QB_QueryClause clause : queryClausesToProcess) {
            clauses.add(clause.build());
        }

        return String.join(new List<String>(clauses), '\n');
    }
}
