public class QS {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        clauses.set(2, QC.QFrom.of(ofObject));
    }

    // Fields

    public QS fields(QB_Fields fields) {
        clauses.set(0, fields);
        return this;
    }

    // SubQuery

    public QS subquery() {
        return this;
    }

    // Scope

    public QS delegatedScope() {
        return scope(QC.Scope.delegated());
    }

    public QS mineScope() {
        return scope(QC.Scope.mine());
    }

    public QS mineAndMyGroupsScope() {
        return scope(QC.Scope.mineAndMyGroups());
    }

    public QS myTerritoryScope() {
        return scope(QC.Scope.myTerritory());
    }

    public QS myTeamTerritoryScope() {
        return scope(QC.Scope.myTeamTerritory());
    }

    public QS teamScope() {
        return scope(QC.Scope.team());
    }

    private QS scope(QC.QB_Scope scope) {
        clauses.set(3, scope);
        return this;
    }

    // Where

    public QS whereAre() {
        clauses.set(4, null);
        return this;
    }

    // Security

    public QS withoutSharing() {
        return this;
    }

    public QS intheritedSharing() {
        return this;
    }

    // Group By

    public QS groupBy(QC.QB_GroupBy groupBy) {
        clauses.set(6, groupBy);
        return this;
    }

    // Order By

    public QS orderBy(QC.QB_OrderBy orderBy) {
        clauses.set(7, orderBy);
        return this;
    }

    // Limit

    public QS setLimit(Integer soqlLimit) {
        clauses.set(8, QC.QLimit.set(soqlLimit));
        return this;
    }

    // Offset

    public QS setOffset(Integer soqlOffset) {
        clauses.set(9, QC.QOffset.set(soqlOffset));
        return this;
    }

    // For

    public QS forReference() {
        return setFor(QC.QFor.forReference());
    }

    public QS forView() {
        return setFor(QC.QFor.forView());
    }

    public QS forUpdate() {
        return setFor(QC.QFor.forUpdate());
    }

    public QS allRows() {
        return setFor(QC.QFor.allRows());
    }

    private QS setFor(QC.QB_For qFor) {
        clauses.set(10, qFor);
        return this;
    }

    // Sharing

    public QS sharing() {
        return this;
    }
}

QS.of(Contact.sObjectType)
    .fields(QC.Fields.get(Contact.Name))
    .myTerritoryScope()
    .groupBy(QC.GroupBy.field(Contact.Name))
    .orderBy(QC.OrderBy
        .field(Contact.FirstName)
        .field(Contact.LastName)
        .sortAsc()
        .nullLast()
    )
    .whereAre(QC.Conditions
        .add(QC.Condition.field(Contact.FirstName).equal('Test 1'))
        .add(QC.Condition.field(Contact.LastName).equal('Test 2'))
        .add(QC.Conditions
            .add(QC.Condition.field(Contact.LastName).equal('Test 4'))
            .add(QC.Condition.field(Contact.LastName).equal('Test 5'))
            .order('1 AND 2')
        )
        .order('1 OR 2 OR 3')
    )
    .forUpdate()
    .setLimit(10)
    .setOffset(1000)
    .asList();
