public class QB extends QB_QueryClause {

    protected Set<QB_QueryClause> queryClauses;

    QB_Scope scope = null;

    protected QB_QueryExecutor queryExecutor;

    public QB(sObjectType objectType) {
        this(objectType.getDescribe().getName());
    }

    public QB(String fromObject) {
        // for subQuery
        this.queryClauses = new Set<QB_QueryClause>{ new QB_Fields(), new QB_From(fromObject), new QB_WithSecurityEnforced() };
        this.queryExecutor = new QB_QueryExecutor();
    }

    public QB withClause(QB_QueryClause clause) {
        this.addQueryClause(clause);
        return this;
    }

    // Fields

    public QB withFields(List<sObjectField> fields) {
        this.addQueryClause(new QB_Fields(fields));
        return this;
    }

    public QB withFields(String commaSeparatedFieldsNames) {
        this.addQueryClause(new QB_Fields(commaSeparatedFieldsNames));
        return this;
    }

    public QB withFields(QB_Fields fields) {
        this.addQueryClause(fields);
        return this;
    }

    // SubQuery

    public QB withSubQuery(QB subQueryBuilder) {
        return this.addQueryClause(new QB_SubQuery(subQueryBuilder));
    }

    public QB withSubQueries(QB_SubQuery subQueryBuilder) {
        return this.addQueryClause(subQueryBuilder);
    }

    // Scope

    public QB withDelegatedScope() {
        return this.addQueryClause(new QB_Scope().withDelegated());
    }

    public QB withMineScope() {
        return this.addQueryClause(new QB_Scope().withMine());
    }

    public QB withMineAndMyGroupsScope() {
        return this.addQueryClause(new QB_Scope().withMineAndMyGroups());
    }

    public QB withMyTerritoryScope() {
        return this.addQueryClause(new QB_Scope().withMyTerritory());
    }

    public QB withMyTeamTerritoryScope() {
        return this.addQueryClause(new QB_Scope().withMyTeamTerritory());
    }

    public QB withTeamScope() {
        return this.addQueryClause(new QB_Scope().withTeam());
    }

    //  Where

    public QB withWhere(QB_Condition queryCondition) {
        return this.addQueryClause(new QB_ConditionsGroup().addCondition(queryCondition));
    }

    public QB withWhere(List<QB_Condition> queryConditions) {
        return this.addQueryClause(new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB withWhere(List<QB_Condition> queryConditions, String conditionOrder) {
        return this.addQueryClause(new QB_ConditionsGroup().addConditions(queryConditions, conditionOrder));
    }

    public QB withWhere(QB_Conditions queryConditions) {
        return this.addQueryClause(new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB withWhere(QB_ConditionsGroup queryConditionsBuilder) {
        return this.addQueryClause(queryConditionsBuilder);
    }

    // Security

    public QB withoutSecurityEnforced() {
        this.queryClauses.remove(new QB_WithSecurityEnforced());
        return this;
    }

    public QB withoutSharing() {
        this.queryExecutor.withoutSharing();
        return this;
    }

    // Group By

    public QB withGroupBy(sObjectField field) {
        return this.addQueryClause(new QB_GroupBy(field));
    }

    public QB withGroupBy(List<sObjectField> fields) {
        return this.addQueryClause(new QB_GroupBy(fields));
    }

    // Order By

    public QB withAscOrder(sObjectField field) {
        return this.addQueryClause(new QB_OrderBy(field).setAscOrder());
    }

    public QB withDescOrder(sObjectField field) {
        return this.addQueryClause(new QB_OrderBy(field).setDescOrder());
    }

    // Limit

    public QB withLimit(Integer soqlLimit) {
        return this.addQueryClause(new QB_Limit(soqlLimit));
    }

    // Offset

    public QB withOffset(Integer soqlOffset) {
        return this.addQueryClause(new QB_Offset(soqlOffset));
    }

    // For

    public QB withForReference() {
        return this.addQueryClause(new QB_For().setForReference());
    }

    public QB withForView() {
        return this.addQueryClause(new QB_For().setForView());
    }

    public QB withForUpdate() {
        return this.addQueryClause(new QB_For().setForUpdate());
    }

    public QB withForAllRows() {
        return this.addQueryClause(new QB_For().setAllRows());
    }

    // Mocking

    public QB withMocking(String modulName) {
        this.queryExecutor.withTestResultMock(modulName);
        return this;
    }

    // Result

    public List<sObject> toListWithPreview() {
        //to debug
        String soqlQuery = this.build();
        QB_Preview.displayQuery(soqlQuery);

        List<sObject> results = this.queryExecutor.withQuery(soqlQuery).toList();
        QB_Preview.displayResults(results);

        return results;
    }

    public List<sObject> toList() {
        return this.queryExecutor.withQuery(this.build()).toList();
    }

    public sObject toObjectWithPreview() {
        //to debug
        String soqlQuery = this.build();
        QB_Preview.displayQuery(soqlQuery);

        sObject result = this.queryExecutor.withQuery(soqlQuery).toObject();
        QB_Preview.displayResults(result);

        return result;
    }

    public sObject toObject() {
        return this.queryExecutor.withQuery(this.build()).toObject();
    }

    private QB addQueryClause(QB_QueryClause queryClause) {
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

        return String.join(new List<String>(clauses), ' ');
    }

    public override String validate() {
        String queryErrors = '';

        for (QB_QueryClause clause : new List<QB_QueryClause>(queryClauses)) {
            queryErrors += clause.validate();
        }

        if (String.isNotEmpty(queryErrors)) {
            this.throwQueryException(queryErrors);
        }

        return queryErrors;
    }

    private void throwQueryException(String errorMessage) {
        QueryException e = new QueryException();
        e.setMessage('\n\n============ Query Errors ============\n\n' + errorMessage + '\n=======================================\n');
        throw e;
    }
}
