public inherited sharing abstract class QS {
    private QB soqlBuilder;
    private QB_QueryExecutor soqlExecutor;

    public QS(sObjectType objectType) {
        this.soqlBuilder = new QB(objectType);
        this.soqlExecutor = new QB_QueryExecutor(this.soqlBuilder);
    }

    // Fields

    public QS fields(List<sObjectField> fields) {
        this.soqlBuilder.qbFields().add(fields);
        return this;
    }

    public QS fields(String commaSeparatedFields) {
        this.soqlBuilder.qbFields().add(commaSeparatedFields);
        return this;
    }

    public QS relationship(String relationshipName, List<sObjectField> fields) {
        this.soqlBuilder.qbFields().add(relationshipName, fields);
        return this;
    }

    // SubQuery

    public QS subQuery(QB_Sub subQueryBuilder) {
        this.soqlBuilder.qbSubQuery().add(subQueryBuilder);
        return this;
    }

    // Scope

    public QS delegatedScope() {
        this.soqlBuilder.qbScope().withDelegated();
        return this;
    }

    public QS mineScope() {
        this.soqlBuilder.qbScope().withMine();
        return this;
    }

    public QS mineAndMyGroupsScope() {
        this.soqlBuilder.qbScope().withMineAndMyGroups();
        return this;
    }

    public QS myTerritoryScope() {
        this.soqlBuilder.qbScope().withMyTerritory();
        return this;
    }

    public QS myTeamTerritoryScope() {
        this.soqlBuilder.qbScope().withMyTeamTerritory();
        return this;
    }

    public QS teamScope() {
        this.soqlBuilder.qbScope().withTeam();
        return this;
    }

    // Where

    public QS condition(QB_ConditionClause condition) {
        this.soqlBuilder.qbConditions().condition(condition);
        return this;
    }

    public QS conditionsOrder(String conditionsOrder) {
        // e.g (1 OR 2) AND 3
        this.soqlBuilder.qbConditions().conditionsOrder(conditionsOrder);
        return this;
    }

    // Security

    public QS withoutSecurityEnforced() {
        this.soqlBuilder.withoutSecurityEnforced();
        return this;
    }

    public QS withSharing() {
        this.soqlExecutor.withSharing();
        return this;
    }

    public QS withoutSharing() {
        this.soqlExecutor.withoutSharing();
        return this;
    }

    // Group By

    public QS groupBy(sObjectField field) {
        this.soqlBuilder.qbGroupBy().add(field);
        return this;
    }

    public QS groupBy(List<sObjectField> fields) {
        this.soqlBuilder.qbGroupBy().add(fields);
        return this;
    }

    // Order By

    public QS ascOrder(sObjectField field) {
        this.soqlBuilder.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QS ascOrder(String field) {
        this.soqlBuilder.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QS descOrder(sObjectField field) {
        this.soqlBuilder.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QS descOrder(String field) {
        this.soqlBuilder.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QS nullsFirst() {
        this.soqlBuilder.qbOrderBy().setNullsFirstOrder();
        return this;
    }

    public QS nullsLast() {
        this.soqlBuilder.qbOrderBy().setNullsLastOrder();
        return this;
    }

    // Limit

    public QS setLimit(Integer soqlLimit) {
        this.soqlBuilder.qbLimit().set(soqlLimit);
        return this;
    }

    // Offset

    public QS setOffset(Integer soqlOffset) {
        this.soqlBuilder.qbOffset().set(soqlOffset);
        return this;
    }

    // For

    public QS forReference() {
        this.soqlBuilder.qbFor().withForReferece();
        return this;
    }

    public QS forView() {
        this.soqlBuilder.qbFor().withForView();
        return this;
    }

    public QS forUpdate() {
        this.soqlBuilder.qbFor().withForUpdate();
        return this;
    }

    public QS allRows() {
        this.soqlBuilder.qbFor().withAllRows();
        return this;
    }

    // Mocking

    public QS mocking(String queryIdentifier) {
        this.soqlExecutor.withTestResultMock(queryIdentifier);
        return this;
    }

    // Preview

    public QS preview() {
        this.soqlExecutor.preview();
        return this;
    }

    // Result

    public sObject toSObject() {
        return this.soqlExecutor.toSObject();
    }

    public List<sObject> toSObjects() {
        return this.soqlExecutor.toSObjectList();
    }
}
