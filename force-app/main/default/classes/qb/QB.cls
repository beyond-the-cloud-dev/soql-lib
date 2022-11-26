public inherited sharing virtual class QB extends QB_QueryClause {
    private List<QB_QueryClause> queryClauses = new QB_QueryClause[11];
    private QB_QueryExecutor queryExecutor = null;

    public QB(sObjectType fromObject) {
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(fromObject));
        this.queryClauses.set(5, new QB_WithSecurityEnforced(fromObject)); // clause is only supported on top-level queries

        this.queryExecutor = new QB_QueryExecutor(fromObject);
    }

    // Fields

    public QB fields(List<sObjectField> fields) {
        this.qbFields().add(fields);
        return this;
    }

    public QB fields(String commaSeparatedFields) {
        this.qbFields().add(commaSeparatedFields);
        return this;
    }

    public QB relationship(String relationshipName, List<sObjectField> fields) {
        this.qbFields().add(relationshipName, fields);
        return this;
    }

    private QB_Fields qbFields() {
        return (QB_Fields) get(0, QB_Fields.class);
    }

    // SubQuery

    public QB subQuery(QB_SubQuery subQueryBuilder) {
        this.qbSubQuery().add(subQueryBuilder);
        return this;
    }

    private QB_SubQueries qbSubQuery() {
        return (QB_SubQueries) get(2, QB_SubQueries.class);
    }

    // Scope

    public QB delegatedScope() {
        this.qbScope().withDelegated();
        return this;
    }

    public QB mineScope() {
        this.qbScope().withMine();
        return this;
    }

    public QB mineAndMyGroupsScope() {
        this.qbScope().withMineAndMyGroups();
        return this;
    }

    public QB myTerritoryScope() {
        this.qbScope().withMyTerritory();
        return this;
    }

    public QB myTeamTerritoryScope() {
        this.qbScope().withMyTeamTerritory();
        return this;
    }

    public QB teamScope() {
        this.qbScope().withTeam();
        return this;
    }

    private QB_Scope qbScope() {
        return (QB_Scope) get(3, QB_Scope.class);
    }

    // Where

    public QB condition(QB_ConditionClause conditionClause) {
        this.qbConditions().add(conditionClause);
        return this;
    }

    public QB conditionsOrder(String conditionsOrder) {
        this.qbConditions().order(conditionsOrder);
        return this;
    }

    private QB_ConditionsGroup qbConditions() {
        return (QB_ConditionsGroup) get(4, QB_ConditionsGroup.class);
    }

    // Security

    public QB withoutSecurityEnforced() {
        this.queryClauses.set(5, null);
        return this;
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
        this.qbGroupBy().add(field);
        return this;
    }

    public QB groupBy(List<sObjectField> fields) {
        this.qbGroupBy().add(fields);
        return this;
    }

    private QB_GroupBy qbGroupBy() {
        return (QB_GroupBy) get(6, QB_GroupBy.class);
    }

    // Order By

    public QB ascOrder(sObjectField field) {
        this.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB ascOrder(String field) {
        this.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB descOrder(sObjectField field) {
        this.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB descOrder(String field) {
        this.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB nullFirst() {
        this.qbOrderBy().setNullsFirstOrder();
        return this;
    }

    public QB nullLast() {
        this.qbOrderBy().setNullsLastOrder();
        return this;
    }

    private QB_OrderBy qbOrderBy() {
        return (QB_OrderBy) get(7, QB_OrderBy.class);
    }

    // Limit

    public QB setLimit(Integer soqlLimit) {
        this.qbLimit().set(soqlLimit);
        return this;
    }

    private QB_Limit qbLimit() {
        return (QB_Limit) get(8, QB_Limit.class);
    }

    // Offset

    public QB setOffset(Integer soqlOffset) {
        this.qbOffset().set(soqlOffset);
        return this;
    }

    private QB_Offset qbOffset() {
        return (QB_Offset) get(9, QB_Offset.class);
    }

    // For

    public QB forReference() {
        this.qbFor().withForReferece();
        return this;
    }

    public QB forView() {
        this.qbFor().withForView();
        return this;
    }

    public QB forUpdate() {
        this.qbFor().withForUpdate();
        return this;
    }

    public QB allRows() {
        this.qbFor().withAllRows();
        return this;
    }

    private QB_For qbFor() {
        return (QB_For) get(10, QB_For.class);
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

    public QB_QueryClause get(Integer index, System.Type queryClauseClass) {
        QB_QueryClause qc = this.queryClauses.get(index);
        if (qc == null) {
            qc = (QB_QueryClause) queryClauseClass.newInstance();
            this.queryClauses.set(index, qc);
        }
        return qc;
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
