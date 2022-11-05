public class QB_QueryBuilder extends QB_QueryClause {

    // TODO
    // 1. with or set or add - builder pattern
    // 2. Constructors or methods
    // 3. A few methods per clause that can override each other

    protected Set<QB_QueryClause> queryClauses;

    public QB_QueryBuilder(sObjectType objectType) {
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(objectType), new QB_WithSecurityEnforced() };
    }

    public QB_QueryBuilder(String fromObject) { // for subQuery
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(fromObject), new QB_WithSecurityEnforced() };
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

    public QB_QueryBuilder withSubQuery(QB_QueryBuilder subQueryBuilder) {
        return this.addQueryClause(new QB_SubQuery(subQueryBuilder));
    }

    public QB_QueryBuilder withSubQueries(QB_SubQuery subQueryBuilder) {
        return this.addQueryClause(subQueryBuilder);
    }

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

    public QB_QueryBuilder withoutSecurityEnforced() {
        this.queryClauses.remove(new QB_WithSecurityEnforced());
        return this;
    }

    // Group By

    public QB_QueryBuilder withGroupBy(sObjectField field) {
        return this.addQueryClause(new QB_GroupBy(field));
    }

    public QB_QueryBuilder withGroupBy(List<sObjectField> fields) {
        return this.addQueryClause(new QB_GroupBy(fields));
    }

    // Order By

    public QB_QueryBuilder withAscOrder(sObjectField field) {
        return this.addQueryClause(new QB_OrderBy(field).setAscOrder());
    }

    public QB_QueryBuilder withDescOrder(sObjectField field) {
        return this.addQueryClause(new QB_OrderBy(field).setDescOrder());
    }

    // Limit

    public QB_QueryBuilder withLimit(Integer soqlLimit) {
        return this.addQueryClause(new QB_Limit(soqlLimit));
    }

    // Offset

    public QB_QueryBuilder withOffset(Integer soqlOffset) {
        return this.addQueryClause(new QB_Offset(soqlOffset));
    }

    // For

    public QB_QueryBuilder withForReference() {
        return this.addQueryClause(new QB_For().setForReference());
    }

    public QB_QueryBuilder withForView() {
        return this.addQueryClause(new QB_For().setForView());
    }

    public QB_QueryBuilder withForUpdate() {
        return this.addQueryClause(new QB_For().setForUpdate());
    }

    public QB_QueryBuilder withForAllRows() {
        return this.addQueryClause(new QB_For().setAllRows());
    }

    // Unit Test

    private QB_QueryBuilder addQueryClause(QB_QueryClause queryClause) {
        // Add element to the set if it is not already present,
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
