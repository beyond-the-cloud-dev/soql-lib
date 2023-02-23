public with sharing class QS {
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
        //TODO
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
        //TODO
        return this;
    }

    // Group By

    public QS groupBy(sObjectField field) {
        config.groupBy.field(field);
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
        //TODO
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

    public QS securityEnforced() {
        config.with.securityEnforced();
        return this;
    }

    public QS systemMode() {
        config.with.systemMode();
        return this;
    }

    public QS intheritedSharing() {
        //TODO
        return this;
    }

    public QS withoutSharing() {
        //TODO
        return this;
    }

    // Result

    public sObject asObject() {
        return null;
    }

    public List<sObject> asList() {
        return null;
    }
}

// QS.of(Contact.sObjectType)
//     .fields(new List<sObjectField>{})
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
