public class QB_QueryBuilder extends QB_QueryClause {

    // TODO
    // 1. with or set or add - builder pattern
    // 2. Constructors or methods
    // 3. A few methods per clause that can override each other

    protected Set<QB_QueryClause> queryClauses;

    public QB_QueryBuilder(sObjectType objectType) {
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(objectType) };
    }

    public QB_QueryBuilder(String fromObject) { // for subQuery
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(fromObject) };
    }

    // Fields

    public QB_QueryBuilder withFields(List<sObjectField> fields) {
        this.addQueryClause(new QB_Fields(fields));
        return this;
    }

    public QB_QueryBuilder withFields(String commaSeparatedFieldsNames) {
        this.addQueryClause(new QB_Fields(commaSeparatedFieldsNames));
        return this;
    }

    // SubQuery

    // Scope

    public QB_QueryBuilder withScope(QB_Scope qbScope) {
        return this.addQueryClause(qbScope);
    }

    //  Where

    public QB_QueryBuilder withCondition(QB_Condition queryCondition) {
        return this.addQueryClause(new QB_ConditionsGroup().addCondition(queryCondition));
    }

    public QB_QueryBuilder withConditions(List<QB_Condition> queryConditions) {
        return this.addQueryClause(new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB_QueryBuilder withConditions(List<QB_Condition> queryConditions, String conditionOrder) {
        return this.addQueryClause(new QB_ConditionsGroup().addConditions(queryConditions, conditionOrder));
    }

    public QB_QueryBuilder withConditions(QB_Conditions queryConditions) {
        return this.addQueryClause(new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB_QueryBuilder withConditions(QB_ConditionsGroup queryConditionsBuilder) {
        return this.addQueryClause(queryConditionsBuilder);
    }

    // Security

    // Group By

    // Order By

    // Limit

    // Offset

    // For

    // Unit Test

    private QB_QueryBuilder addQueryClause(QB_QueryClause queryClause) {
        // Add will ad an element to the set if it is not already present,
        // but because there can be element, we need to remove it first to override
        this.queryClauses.remove(queryClause);
        this.queryClauses.add(queryClause);
        return this;
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
