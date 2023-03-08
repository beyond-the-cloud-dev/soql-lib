public inherited sharing class QS {
    private static QB_Bind bind;

    private QB builder;
    private QB_Executor executor;

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        bind = new QB_Bind();
        builder = new QB(ofObject);
        executor = new QB_Executor();
    }

    public static QB_Sub SubQuery {
        get {
            return QB_Sub.subQueryWithBinder(bind);
        }
    }

    public static QB_ConditionsGroup ConditionGroup {
        get {
            return QB_ConditionsGroup.newGroup();
        }
    }

    public static QB_Condition Condition {
        get {
            return QB_Condition.conditionWithBinder(bind);
        }
    }

    public static QB_Join JoinQuery {
        get {
            return QB_Join.joinWithBinder(bind);
        }
    }

    // Fields

    public QS count() {
        builder.fields.count();
        executor.countQuery();
        return this;
    }

    public QS count(sObjectField field) {
        builder.fields.count(field);
        executor.countQuery();
        return this;
    }

    public QS grouping(sObjectField field) {
        builder.fields.grouping(field);
        return this;
    }

    public QS grouping(sObjectField field, String alias) {
        builder.fields.grouping(field, alias);
        return this;
    }

    public QS field(sObjectField field) {
        builder.fields.retrive(field);
        return this;
    }

    public QS fields(List<sObjectField> fields) {
        builder.fields.retrive(fields);
        return this;
    }

    public QS relatedFields(String relationshipPath, List<sObjectField> fields) {
        builder.fields.retrive(relationshipPath, fields);
        return this;
    }

    // SubQuery

    public QS subquery(QB_Sub subQuery) {
        builder.subQueries.add(subQuery);
        return this;
    }

    // Scope

    public QS delegatedScope() {
        builder.scope.delegated();
        return this;
    }

    public QS mineScope() {
        builder.scope.mine();
        return this;
    }

    public QS mineAndMyGroupsScope() {
        builder.scope.mineAndMyGroups();
        return this;
    }

    public QS myTerritoryScope() {
        builder.scope.myTerritory();
        return this;
    }

    public QS myTeamTerritoryScope() {
        builder.scope.myTeamTerritory();
        return this;
    }

    public QS teamScope() {
        builder.scope.team();
        return this;
    }

    // Where

    public QS whereAre(QB_ConditionsGroup conditions) {
        builder.conditions = conditions;
        return this;
    }

    // Group By

    public QS groupBy(sObjectField field) {
        builder.groupBy.field(field);
        return this;
    }

    public QS groupByRollup(sObjectField field) {
        builder.groupBy.rollup(field);
        return this;
    }

    public QS groupByCube(sObjectField field) {
        builder.groupBy.cube(field);
        return this;
    }

    // Order By

    public QS orderBy(sObjectField field) {
        builder.orderBy.field(field);
        return this;
    }

    public QS orderByGrouping(sObjectField field) {
        builder.orderBy.grouping(field);
        return this;
    }

    public QS orderByRelated(String path, sObjectField field) {
        builder.orderBy.relatedField(path, field);
        return this;
    }

    public QS orderByRelated(String path, List<sObjectField> fields) {
        builder.orderBy.relatedFields(path, fields);
        return this;
    }

    public QS sortAsc() {
        builder.orderBy.sortAsc();
        return this;
    }

    public QS sortDesc() {
        builder.orderBy.sortDesc();
        return this;
    }

    public QS nullsFirst() {
        builder.orderBy.nullsFirst();
        return this;
    }

    public QS nullsLast() {
        builder.orderBy.nullsLast();
        return this;
    }

    // Limit

    public QS setLimit(Integer amount) {
        builder.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public QS setOffset(Integer startingRow) {
        builder.soqlOffset.fromRow(startingRow);
        return this;
    }

    // For

    public QS forReference() {
        builder.soqlFor.forReference();
        return this;
    }

    public QS forView() {
        builder.soqlFor.forView();
        return this;
    }

    public QS forUpdate() {
        builder.soqlFor.forUpdate();
        return this;
    }

    public QS allRows() {
        builder.soqlFor.allRows();
        return this;
    }

    // Sharing

    public QS systemMode() {
        executor.systemMode();
        return this;
    }

    public QS withSharing() {
        executor.withSharing();
        return this;
    }

    public QS withoutSharing() {
        executor.withoutSharing();
        return this;
    }

    // Mocking

    public QS mocking(String queryIdentifier) {
        executor.mocking(queryIdentifier);
        return this;
    }

    // Result

    public QS preview() {
        executor.preview();
        return this;
    }

    public sObject asObject() {
        return executor.evaluate(builder.build(), bind.build()).asObject();
    }

    public List<sObject> asList() {
        return executor.evaluate(builder.build(), bind.build()).asList();
    }

    public Integer asInteger() {
        return executor.evaluate(builder.build(), bind.build()).asInteger();
    }

    // Standard

    public sObject getById(Id recordId) {
        return whereAre(QS.ConditionGroup.add(QS.Condition.field(Account.Id).equal(recordId))).asObject();
    }

    public List<sObject> getByIds(List<Id> recordIds) {
        return whereAre(QS.ConditionGroup.add(QS.Condition.field(Account.Id).inCollection(recordIds))).asList();
    }
}
