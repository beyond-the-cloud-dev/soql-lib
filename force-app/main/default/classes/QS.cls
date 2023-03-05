public inherited sharing class QS {
    private static QBB qbb;

    private QB qb;
    private QBE qbe;

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        qbb = new QBB();
        qb = new QB(ofObject);
        qbe = new QBE();
    }

    public static QB_Sub SubQuery {
        get {
            return QB_Sub.subQueryWithBinder(qbb);
        }
    }

    public static QB_ConditionsGroup ConditionGroup {
        get {
            return QB_ConditionsGroup.newGroup();
        }
    }

    public static QB_Condition Condition {
        get {
            return QB_Condition.conditionWithBinder(qbb);
        }
    }

    public static QB_Join JoinQuery {
        get {
            return QB_Join.joinWithBinder(qbb);
        }
    }

    // Fields

    public QS count() {
        qb.fields.count();
        qbe.countQuery();
        return this;
    }

    public QS count(sObjectField field) {
        qb.fields.count(field);
        qbe.countQuery();
        return this;
    }

    public QS grouping(sObjectField field) {
        qb.fields.grouping(field);
        return this;
    }

    public QS grouping(sObjectField field, String alias) {
        qb.fields.grouping(field, alias);
        return this;
    }

    public QS fields(List<sObjectField> fields) {
        qb.fields.retrive(fields);
        return this;
    }

    public QS relatedFields(String relationshipPath, List<sObjectField> fields) {
        qb.fields.retrive(relationshipPath, fields);
        return this;
    }

    // SubQuery

    public QS subquery(QB_Sub subQuery) {
        qb.subQueries.add(subQuery);
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

    public QS whereAre(QB_ConditionsGroup conditions) {
        qb.conditions = conditions;
        return this;
    }

    // Group By

    public QS groupBy(sObjectField field) {
        qb.groupBy.field(field);
        return this;
    }

    public QS groupByRollup(sObjectField field) {
        qb.groupBy.rollup(field);
        return this;
    }

    public QS groupByCube(sObjectField field) {
        qb.groupBy.cube(field);
        return this;
    }

    // Order By

    public QS orderBy(sObjectField field) {
        qb.orderBy.field(field);
        return this;
    }

    public QS orderByGrouping(sObjectField field) {
        qb.orderBy.grouping(field);
        return this;
    }

    public QS orderByRelated(String path, sObjectField field) {
        qb.orderBy.relatedField(path, field);
        return this;
    }

    public QS orderByRelated(String path, List<sObjectField> fields) {
        qb.orderBy.relatedFields(path, fields);
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

    public QS preview() {
        qbe.preview();
        return this;
    }

    public sObject asObject() {
        return qbe.evaluate(qb.build(), qbb.build()).asObject();
    }

    public List<sObject> asList() {
        return qbe.evaluate(qb.build(), qbb.build()).asList();
    }

    public Integer asInteger() {
        return qbe.evaluate(qb.build(), qbb.build()).asInteger();
    }
}
