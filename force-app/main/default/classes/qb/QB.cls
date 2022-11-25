public inherited sharing virtual class QB extends QB_QueryClause {
    protected List<QB_QueryClause> queryClauses = new QB_QueryClause[11];
    protected QB_QueryExecutor queryExecutor = new QB_QueryExecutor();

    public QB(sObjectType fromObject) {
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(fromObject));
        this.queryClauses.set(5, new QB_WithSecurityEnforced(fromObject)); // clause is only supported on top-level queries

        this.queryExecutor = new QB_QueryExecutor(fromObject);
    }

    public QB(String fromObject) {
        // for sub-query
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(fromObject));

        this.queryExecutor = new QB_QueryExecutor();
    }

    // Fields

    public QB fields(List<sObjectField> fields) {
        return this.addQueryClause(0, this.qbFields().add(fields));
    }

    public QB fields(String commaSeparatedFields) {
        return this.addQueryClause(0, this.qbFields().add(commaSeparatedFields));
    }

    public QB relationship(String relationshipName, List<sObjectField> fields) {
        return this.addQueryClause(0, this.qbFields().add(relationshipName, fields));
    }

    private QB_Fields qbFields() {
        return (QB_Fields) queryClauses.get(0);
    }

    // SubQuery

    public QB subQuery(QB subQueryBuilder) {
        return this.addQueryClause(1, new QB_SubQuery().add(subQueryBuilder));
    }

    public QB subQueries(List<QB> subQueryBuilders) {
        return this.addQueryClause(1, new QB_SubQuery().add(subQueryBuilders));
    }

    // Scope

    public QB delegatedScope() {
        return this.addQueryClause(3, new QB_Scope().withDelegated());
    }

    public QB mineScope() {
        return this.addQueryClause(3, new QB_Scope().withMine());
    }

    public QB mineAndMyGroupsScope() {
        return this.addQueryClause(3, new QB_Scope().withMineAndMyGroups());
    }

    public QB myTerritoryScope() {
        return this.addQueryClause(3, new QB_Scope().withMyTerritory());
    }

    public QB myTeamTerritoryScope() {
        return this.addQueryClause(3, new QB_Scope().withMyTeamTerritory());
    }

    public QB teamScope() {
        return this.addQueryClause(3, new QB_Scope().withTeam());
    }

    // Where

    public QB conditions(QB_ConditionsGroup queryConditionsBuilder) {
        return this.addQueryClause(4, queryConditionsBuilder.top());
    }

    // Security

    public QB withoutSecurityEnforced() {
        return this.addQueryClause(5, null);
    }

    public QB withSharing() {
        this.queryExecutor.withSharing();
        return this;
    }

    public QB withoutSharing() {
        this.queryExecutor.withoutSharing();
        return this;
    }

    // Group By

    public QB groupBy(sObjectField field) {
        return this.addQueryClause(6, new QB_GroupBy(field));
    }

    public QB groupBy(List<sObjectField> fields) {
        return this.addQueryClause(6, new QB_GroupBy(fields));
    }

    // Order By

    //TODO Nulls

    public QB ascOrder(sObjectField field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setAscOrder());
    }

    public QB ascOrder(String field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setAscOrder());
    }

    public QB descOrder(sObjectField field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setDescOrder());
    }

    public QB descOrder(String field) {
        return this.addQueryClause(7, new QB_OrderBy(field).setDescOrder());
    }

    // Limit

    public QB setLimit(Integer soqlLimit) {
        return this.addQueryClause(8, new QB_Limit(soqlLimit));
    }

    // Offset

    public QB setOffset(Integer soqlOffset) {
        return this.addQueryClause(9, new QB_Offset(soqlOffset));
    }

    // For

    public QB forReference() {
        return this.addQueryClause(10, new QB_For().withForReferece());
    }

    public QB forView() {
        return this.addQueryClause(10, new QB_For().withForView());
    }

    public QB forUpdate() {
        return this.addQueryClause(10, new QB_For().withForUpdate());
    }

    public QB allRows() {
        return this.addQueryClause(10, new QB_For().withAllRows());
    }

    // Mocking

    public QB mocking(String queryIdentifier) {
        this.queryExecutor.withTestResultMock(queryIdentifier);
        return this;
    }

    // Preview

    public QB preview() {
        this.queryExecutor.withPreview();
        return this;
    }

    // Result

    public sObject toSObject() {
        return this.queryExecutor.toSObject(this.build());
    }

    public List<sObject> toSObjects() {
        return this.queryExecutor.toSObjectList(this.build());
    }

    // Helpers

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
