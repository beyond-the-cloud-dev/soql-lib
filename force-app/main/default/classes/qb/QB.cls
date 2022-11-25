public inherited sharing virtual class QB extends QB_QueryClause {
    protected QB_QueryExecutor queryExecutor = null;
    protected QB_Storage storage = null;

    public QB(sObjectType fromObject) {
        this.storage = new QB_Storage(fromObject);
        this.queryExecutor = new QB_QueryExecutor(fromObject);
    }

    public QB(String fromObject) {
        this.storage = new QB_Storage(fromObject);
        this.queryExecutor = new QB_QueryExecutor();
    }

    // Fields

    public QB fields(List<sObjectField> fields) {
        this.storage.qbFields().add(fields);
        return this;
    }

    public QB fields(String commaSeparatedFields) {
        this.storage.qbFields().add(commaSeparatedFields);
        return this;
    }

    public QB relationship(String relationshipName, List<sObjectField> fields) {
        this.storage.qbFields().add(relationshipName, fields);
        return this;
    }

    // SubQuery

    public QB subQuery(QB subQueryBuilder) {
        this.storage.qbSubQuery().add(subQueryBuilder);
        return this;
    }

    // Scope

    public QB delegatedScope() {
        this.storage.qbScope().withDelegated();
        return this;
    }

    public QB mineScope() {
        this.storage.qbScope().withMine();
        return this;
    }

    public QB mineAndMyGroupsScope() {
        this.storage.qbScope().withMineAndMyGroups();
        return this;
    }

    public QB myTerritoryScope() {
        this.storage.qbScope().withMyTerritory();
        return this;
    }

    public QB myTeamTerritoryScope() {
        this.storage.qbScope().withMyTeamTerritory();
        return this;
    }

    public QB teamScope() {
        this.storage.qbScope().withTeam();
        return this;
    }

    // Where

    public QB condition(QB_ConditionClause conditionClause) {
        this.storage.qbConditions().add(conditionClause);
        return this;
    }

    public QB conditionsOrder(String conditionsOrder) {
        this.storage.qbConditions().order(conditionsOrder);
        return this;
    }

    // Security

    public QB withoutSecurityEnforced() {
        this.storage.removeSecurityEnforced();
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
        this.storage.qbGroupBy().add(field);
        return this;
    }

    public QB groupBy(List<sObjectField> fields) {
        this.storage.qbGroupBy().add(fields);
        return this;
    }

    // Order By

    public QB ascOrder(sObjectField field) {
        this.storage.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB ascOrder(String field) {
        this.storage.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB descOrder(sObjectField field) {
        this.storage.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB descOrder(String field) {
        this.storage.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB nullFirst() {
        this.storage.qbOrderBy().setNullsFirstOrder();
        return this;
    }

    public QB nullLast() {
        this.storage.qbOrderBy().setNullsLastOrder();
        return this;
    }

    // Limit

    public QB setLimit(Integer soqlLimit) {
        this.storage.qbLimit().set(soqlLimit);
        return this;
    }

    // Offset

    public QB setOffset(Integer soqlOffset) {
        this.storage.qbOffset().set(soqlOffset);
        return this;
    }

    // For

    public QB forReference() {
        this.storage.qbFor().withForReferece();
        return this;
    }

    public QB forView() {
        this.storage.qbFor().withForView();
        return this;
    }

    public QB forUpdate() {
        this.storage.qbFor().withForUpdate();
        return this;
    }

    public QB allRows() {
        this.storage.qbFor().withAllRows();
        return this;
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

    public override String build() {
        this.validate();

        List<String> clauses = new List<String>();

        for (QB_QueryClause clause : this.storage.queryClauses) {
            if (clause == null) {
                continue;
            }
            clauses.add(clause.build());
        }

        return String.join(new List<String>(clauses), ' ');
    }

    public override String validate() {
        String queryErrors = '';

        for (QB_QueryClause clause : this.storage.queryClauses) {
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
