public inherited sharing class QB_Sub implements QB_QueryClause {
    private QB qb;
    private QBB qbb;

    public QB_Sub(QBB qbb) {
        this.qbb = qbb;
    }

    public QB_Sub of(String ofObject) {
        qb = new QB(ofObject);
        return this;
    }

    // Fields

    public QB_Sub fields(List<sObjectField> fields) {
        qb.fields.retrive(fields);
        return this;
    }

    public QB_Sub relatedFields(String relationshipPath, List<sObjectField> fields) {
        qb.fields.retrive(relationshipPath, fields);
        return this;
    }

    // Where

    public QB_Sub whereAre(QB_ConditionsGroup conditions) {
        qb.conditions = conditions;
        return this;
    }

    // Group By

    public QB_Sub groupBy(sObjectField field) {
        qb.groupBy.field(field);
        return this;
    }

    // Order By

    public QB_Sub orderBy(sObjectField field) {
        qb.orderBy.field(field);
        return this;
    }

    public QB_Sub orderBy(List<sObjectField> fields) {
        qb.orderBy.fields(fields);
        return this;
    }

    public QB_Sub orderByRelationship(String path, sObjectField field) {
        //TODO
        return this;
    }

    public QB_Sub sortAsc() {
        qb.orderBy.sortAsc();
        return this;
    }

    public QB_Sub sortDesc() {
        qb.orderBy.sortDesc();
        return this;
    }

    public QB_Sub nullsFirst() {
        qb.orderBy.nullsFirst();
        return this;
    }

    public QB_Sub nullsLast() {
        qb.orderBy.nullsLast();
        return this;
    }

    // Limit

    public QB_Sub setLimit(Integer amount) {
        qb.soqlLimit.max(amount);
        return this;
    }

    // Offset

    public QB_Sub setOffset(Integer startingRow) {
        qb.soqlOffset.fromRow(startingRow);
        return this;
    }

    // For

    public QB_Sub forReference() {
        qb.soqlFor.forReference();
        return this;
    }

    public QB_Sub forView() {
        qb.soqlFor.forView();
        return this;
    }

    // Build

    public String build() {
        return qb.build();
    }
}
