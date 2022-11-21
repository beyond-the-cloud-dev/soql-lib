public virtual class QB extends QB_QueryClause {

    protected List<QB_QueryClause> queryClauses = new List<QB_QueryClause>(11);
    protected QB_QueryExecutor queryExecutor = new QB_QueryExecutor();

    public QB(sObjectType objectType) {
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(objectType));
        this.queryClauses.set(5, new QB_WithSecurityEnforced()); // clause is only supported on top-level queries
    }

    public QB(String fromObject) { // for sub-query
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(fromObject));
    }

    // Fields

    public QB withFields(List<sObjectField> fields) {
        QB_Fields qbFields = (QB_Fields) queryClauses.get(0);
        return this.addQueryClause(0, qbFields.addFields(fields));
    }

    public QB withRelatedFields(String commaSeparatedFieldsNames) {
        QB_Fields qbFields = (QB_Fields) queryClauses.get(0);
        return this.addQueryClause(0, qbFields.addFields(commaSeparatedFieldsNames));
    }

    // SubQuery

    public QB withSubQuery(QB subQueryBuilder) {
        return this.addQueryClause(1, new QB_SubQuery(subQueryBuilder));
    }

    public QB withSubQueries(List<QB> subQueryBuilders) {
        return this.addQueryClause(1, new QB_SubQuery(subQueryBuilders));
    }

    // Scope

    public QB withDelegatedScope() {
        return this.addQueryClause(3, new QB_Scope().withDelegated());
    }

    public QB withMineScope() {
        return this.addQueryClause(3, new QB_Scope().withMine());
    }

    public QB withMineAndMyGroupsScope() {
        return this.addQueryClause(3, new QB_Scope().withMineAndMyGroups());
    }

    public QB withMyTerritoryScope() {
        return this.addQueryClause(3, new QB_Scope().withMyTerritory());
    }

    public QB withMyTeamTerritoryScope() {
        return this.addQueryClause(3, new QB_Scope().withMyTeamTerritory());
    }

    public QB withTeamScope() {
        return this.addQueryClause(3, new QB_Scope().withTeam());
    }

    // Where

    public QB withWhere(QB_Condition queryCondition) {
        return this.addQueryClause(4, new QB_ConditionsGroup().addCondition(queryCondition));
    }

    public QB withWhere(List<QB_Condition> queryConditions) {
        return this.addQueryClause(4, new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB withWhere(List<QB_Condition> queryConditions, String conditionOrder) {
        return this.addQueryClause(4, new QB_ConditionsGroup().addConditions(queryConditions, conditionOrder));
    }

    public QB withWhere(QB_Conditions queryConditions) {
        return this.addQueryClause(4, new QB_ConditionsGroup().addConditions(queryConditions));
    }

    public QB withWhere(QB_ConditionsGroup queryConditionsBuilder) {
        return this.addQueryClause(4, queryConditionsBuilder);
    }

    // Security

    public QB withoutSecurityEnforced() {
        this.queryClauses.set(5, null);
        return this;
    }

    public QB withoutSharing() {
        this.queryExecutor.withoutSharing();
        return this;
    }

    // Group By

    public QB withGroupBy(sObjectField field) {
        return this.addQueryClause(6, new QB_GroupBy(field));
    }

    public QB withGroupBy(List<sObjectField> fields) {
        return this.addQueryClause(6, new QB_GroupBy(fields));
    }

    // Order By

    //TODO Nulls

    public QB withAscOrder(sObjectField field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setAscOrder());
    }

    public QB withAscOrder(String field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setAscOrder());
    }

    public QB withDescOrder(sObjectField field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setDescOrder());
    }

    public QB withDescOrder(String field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setDescOrder());
    }

    // Limit

    public QB withLimit(Integer soqlLimit) {
        return this.addQueryClause(8, new QB_Limit(soqlLimit));
    }

    // Offset

    public QB withOffset(Integer soqlOffset) {
        return this.addQueryClause(9, new QB_Offset(soqlOffset));
    }

    // For

    public QB withForReference() {
        return this.addQueryClause(10, new QB_For().withForReferece());
    }

    public QB withForView() {
        return this.addQueryClause(10, new QB_For().withForView());
    }

    public QB withForUpdate() {
        return this.addQueryClause(10, new QB_For().withForUpdate());
    }

    public QB withAllRows() {
        return this.addQueryClause(10, new QB_For().withAllRows());
    }

    // Mocking

    public QB withMocking(String queryIdentifier) {
        this.queryExecutor.withTestResultMock(queryIdentifier);
        return this;
    }

    // Result

    public List<sObject> toSObjectListWithPreview() {
        //to debug
        String soqlQuery = this.build();
        QB_Preview.displayQuery(soqlQuery);

        List<sObject> results = this.queryExecutor.toList(soqlQuery);
        QB_Preview.displayResults(results);

        return results;
    }

    public List<sObject> toSObjectList() {
        return this.queryExecutor.toList(this.build());
    }

    public sObject toSObjectWithPreview() {
        //to debug
        String soqlQuery = this.build();
        QB_Preview.displayQuery(soqlQuery);

        sObject result = this.queryExecutor.toObject(soqlQuery);
        QB_Preview.displayResults(result);

        return result;
    }

    public sObject toSObject() {
        return this.queryExecutor.toObject(this.build());
    }

    private QB addQueryClause(Integer index, QB_QueryClause queryClause) {
        this.queryClauses.set(index, queryClause);
        return this;
    }

    public override String build() {
        this.validate();

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
