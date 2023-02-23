public class QS {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];
    private QC config;

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        config = new QC(ofObject);
    }

    // Fields

    public QS fields(List<sObjectField> fields) {
        config.fields.retrive(fields);
        return this;
    }

    public QS relatedFields(String relationshipPath, List<sObjectField> fields) {
        config.fields.retrive(relationshipPath, fields);
        return this;
    }

    // SubQuery

    public QS subquery() {
        return this;
    }

    // Scope

    public QS delegatedScope() {
        config.scope.delegated();
        return this;
    }

    public QS mineScope() {
        config.scope.mine();
        return this;
    }

    public QS mineAndMyGroupsScope() {
        config.scope.mineAndMyGroups();
        return this;
    }

    public QS myTerritoryScope() {
        config.scope.myTerritory();
        return this;
    }

    public QS myTeamTerritoryScope() {
        config.scope.myTeamTerritory();
        return this;
    }

    public QS teamScope() {
        config.scope.team();
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

    public QS orderBy(sObjectField field) {
        config.orderBy.field(field);
        return this;
    }

    public QS orderBy(List<sObjectField> fields) {
        config.orderBy.fields(fields);
        return this;
    }

    public QS orderByRelationship(String path, sObjectField field) {
        // clauses.set(7, orderBy);
        return this;
    }

    public QS sortAsc() {
        config.orderBy.sortAsc();
        return this;
    }

    public QS sortDesc() {
        config.orderBy.sortDesc();
        return this;
    }

    public QS nullsFirst() {
        config.orderBy.nullsFirst();
        return this;
    }

    public QS nullsLast() {
        config.orderBy.nullsLast();
        return this;
    }

    // Limit

    public QS setLimit(Integer amount) {
        config.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public QS setOffset(Integer startingRow) {
        config.soqlOffset.fromRow(startingRow);
        return this;
    }

    // For

    public QS forReference() {
        config.soqlFor.forReference();
        return this;
    }

    public QS forView() {
        config.soqlFor.forView();
        return this;
    }

    public QS forUpdate() {
        config.soqlFor.forUpdate();
        return this;
    }

    public QS allRows() {
        config.soqlFor.allRows();
        return this;
    }

    // Sharing

    public QS sharing() {
        return this;
    }
}

// QS.of(Contact.sObjectType)
//     .fields(QC.Fields.get(Contact.Name))
//     .myTerritoryScope()
//     .groupBy(QC.GroupBy.field(Contact.Name))
//     .orderBy(Contact.FirstName)
//     .sortAsc()
//     .nullLast()
//     .whereAre(QC.Conditions
//         .add(QC.Condition.field(Contact.FirstName).equal('Test 1'))
//         .add(QC.Condition.field(Contact.LastName).equal('Test 2'))
//         .add(QC.Conditions
//             .add(QC.Condition.field(Contact.LastName).equal('Test 4'))
//             .add(QC.Condition.field(Contact.LastName).equal('Test 5'))
//             .order('1 AND 2')
//         )
//         .order('1 OR 2 OR 3')
//     )
//     .forUpdate()
//     .setLimit(10)
//     .setOffset(1000)
//     .asList();
