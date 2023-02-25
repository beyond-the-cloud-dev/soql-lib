public inherited sharing class QS {
    private QB qb;
    private QBE qbe;
    private QBB qbb;

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        qb = new QB(ofObject);
        qbe = new QBE();
        qbb = new QBB();
    }

    public static QB_WhereGroup ConditionsGroup {
        get {
            return new QB_WhereGroup();
        }
    }

    // Fields

    public QS fields(List<sObjectField> fields) {
        qb.fields.retrive(fields);
        return this;
    }

    public QS relatedFields(String relationshipPath, List<sObjectField> fields) {
        qb.fields.retrive(relationshipPath, fields);
        return this;
    }

    // SubQuery

    public QS subquery() {
        //TODO
        return this;
    }

    // Scope

    public QS delegatedScope() {
        qb.scope.delegated();
        return this;
    }

    public QS mineScope() {
        qb.scope.mine();
        return this;
    }

    public QS mineAndMyGroupsScope() {
        qb.scope.mineAndMyGroups();
        return this;
    }

    public QS myTerritoryScope() {
        qb.scope.myTerritory();
        return this;
    }

    public QS myTeamTerritoryScope() {
        qb.scope.myTeamTerritory();
        return this;
    }

    public QS teamScope() {
        qb.scope.team();
        return this;
    }

    // Where

    public QS whereAre(QB_WhereGroup conditions) {
        conditions.setBinder(qbb);
        qb.conditions = conditions;
        return this;
    }

    // Group By

    public QS groupBy(sObjectField field) {
        qb.groupBy.field(field);
        return this;
    }

    // Order By

    public QS orderBy(sObjectField field) {
        qb.orderBy.field(field);
        return this;
    }

    public QS orderBy(List<sObjectField> fields) {
        qb.orderBy.fields(fields);
        return this;
    }

    public QS orderByRelationship(String path, sObjectField field) {
        //TODO
        return this;
    }

    public QS sortAsc() {
        qb.orderBy.sortAsc();
        return this;
    }

    public QS sortDesc() {
        qb.orderBy.sortDesc();
        return this;
    }

    public QS nullsFirst() {
        qb.orderBy.nullsFirst();
        return this;
    }

    public QS nullsLast() {
        qb.orderBy.nullsLast();
        return this;
    }

    // Limit

    public QS setLimit(Integer amount) {
        qb.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public QS setOffset(Integer startingRow) {
        qb.soqlOffset.fromRow(startingRow);
        return this;
    }

    // For

    public QS forReference() {
        qb.soqlFor.forReference();
        return this;
    }

    public QS forView() {
        qb.soqlFor.forView();
        return this;
    }

    public QS forUpdate() {
        qb.soqlFor.forUpdate();
        return this;
    }

    public QS allRows() {
        qb.soqlFor.allRows();
        return this;
    }

    // Sharing

    public QS systemMode() {
        qbe.systemMode();
        return this;
    }

    public QS withSharing() {
        qbe.withSharing();
        return this;
    }

    public QS withoutSharing() {
        qbe.withoutSharing();
        return this;
    }

    // Result

    public sObject asObject() {
        // return qbe.evaluate(qb.build(), binder.build()).asObject();
        return qbe.evaluate(qb.build(), qbb.build()).asObject();
    }

    public List<sObject> asList() {
        return qbe.evaluate(qb.build(), qbb.build()).asList();
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

// List<Account> contacts = (List<Account>) QS.of(Account.sObjectType)
// .fields(new List<sObjectField>{
//     Account.Name
// })
// .setLimit(10)
// .asList();

// System.debug(LoggingLevel.DEBUG, ': ' + contacts);
// SELECT Id, Name FROM Account LIMIT 10
