public class QB extends QB_QueryClause {

    protected List<QB_QueryClause> queryClauses;

    protected QB_QueryExecutor queryExecutor;

    private final Integer NUMBER_OF_CLAUSES = 12;

    public QB(sObjectType objectType) {
        this(objectType.getDescribe().getName());
    }

    public QB(String fromObject) {
        this.queryClauses = new List<QB_QueryClause>(NUMBER_OF_CLAUSES);

        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(1, new QB_From(fromObject));
        this.queryClauses.set(6, new QB_WithSecurityEnforced());

        this.queryExecutor = new QB_QueryExecutor();
    }

    // Fields

    public QB withFields(List<sObjectField> fields) {
        return this.addQueryClause(0, new QB_Fields(fields));
    }

    public QB withFields(String commaSeparatedFieldsNames) {
        return this.addQueryClause(0, new QB_Fields(commaSeparatedFieldsNames));
    }

    public QB withFields(QB_Fields fields) {
        return this.addQueryClause(0, fields);
    }

    // SubQuery

    public QB withSubQuery(QB subQueryBuilder) {
        return this.addQueryClause(2, new QB_SubQuery(subQueryBuilder));
    }

    public QB withSubQueries(QB_SubQuery subQueryBuilder) {
        return this.addQueryClause(2, subQueryBuilder);
    }

    // Scope

    public QB withDelegatedScope() {
        return this.addQueryClause(4, new QB_Scope().withDelegated());
    }

    public QB withMineScope() {
        return this.addQueryClause(4, new QB_Scope().withMine());
    }

    public QB withMineAndMyGroupsScope() {
        return this.addQueryClause(4, new QB_Scope().withMineAndMyGroups());
    }

    public QB withMyTerritoryScope() {
        return this.addQueryClause(4, new QB_Scope().withMyTerritory());
    }

    public QB withMyTeamTerritoryScope() {
        return this.addQueryClause(4, new QB_Scope().withMyTeamTerritory());
    }

    public QB withTeamScope() {
        return this.addQueryClause(4, new QB_Scope().withTeam());
    }

    //  Where

    public QB withWhere(QB_Condition queryCondition) {
        return this.addQueryClause(5, new QB_ConditionsGroup().addCondition(queryCondition));
    }

    public QB withWhere(List<QB_Condition> queryConditions) {
        return this.addQueryClause(5, new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB withWhere(List<QB_Condition> queryConditions, String conditionOrder) {
        return this.addQueryClause(5, new QB_ConditionsGroup().addConditions(queryConditions, conditionOrder));
    }

    public QB withWhere(QB_Conditions queryConditions) {
        return this.addQueryClause(5, new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB withWhere(QB_ConditionsGroup queryConditionsBuilder) {
        return this.addQueryClause(5, queryConditionsBuilder);
    }

    // Security

    public QB withoutSecurityEnforced() {
        this.queryClauses.set(6, null);
        return this;
    }

    public QB withoutSharing() {
        this.queryExecutor.withoutSharing();
        return this;
    }

    // Group By

    public QB withGroupBy(sObjectField field) {
        return this.addQueryClause(7, new QB_GroupBy(field));
    }

    public QB withGroupBy(List<sObjectField> fields) {
        return this.addQueryClause(7, new QB_GroupBy(fields));
    }

    // Order By

    public QB withAscOrder(sObjectField field) {
        return this.addQueryClause(8, new QB_OrderBy(field).setAscOrder());
    }

    public QB withAscOrder(String field) {
        return this.addQueryClause(8, new QB_OrderBy(field).setAscOrder());
    }

    public QB withDescOrder(sObjectField field) {
        return this.addQueryClause(8, new QB_OrderBy(field).setDescOrder());
    }

    public QB withDescOrder(String field) {
        return this.addQueryClause(8, new QB_OrderBy(field).setDescOrder());
    }

    // Limit

    public QB withLimit(Integer soqlLimit) {
        return this.addQueryClause(9, new QB_Limit(soqlLimit));
    }

    // Offset

    public QB withOffset(Integer soqlOffset) {
        return this.addQueryClause(10, new QB_Offset(soqlOffset));
    }

    // For

    public QB withForReference() {
        return this.addQueryClause(11, new QB_For().withForReferece());
    }

    public QB withForView() {
        return this.addQueryClause(11, new QB_For().withForView());
    }

    public QB withForUpdate() {
        return this.addQueryClause(11, new QB_For().withForUpdate());
    }

    public QB withAllRows() {
        return this.addQueryClause(11, new QB_For().withAllRows());
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

    private QB addQueryClause(Integer index, QB_QueryClause queryClause) {
        this.queryClauses.set(index, queryClause);
        return this;
    }

    public override String build() {
        List<String> clauses = new List<String>();

        for (QB_QueryClause clause : this.queryClauses) {
            if (clause == null) {
                continue;
            }
            clauses.add(clause.build());
        }

        return String.join(new List<String>(clauses), ' ');
    }

    public override String validate() {
        String queryErrors = '';

        for (QB_QueryClause clause : this.queryClauses) {
            if (clause == null) {
                continue;
            }
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
