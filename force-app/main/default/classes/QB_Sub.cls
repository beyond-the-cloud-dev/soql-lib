public inherited sharing class QB_Sub implements QB_QueryClause {
    private QBS qbs;
    private QBB qbb;

    public QB_Sub of(String ofObject) {
        // return new QB_Sub(ofObject);
        // qbs.from.of(ofObject);
        return this;
    }

    public QB_Sub(QBB qbb) {
        this.qbb = qbb;
    }

    // Fields

    public QB_Sub fields(List<sObjectField> fields) {
        qbs.fields.retrive(fields);
        return this;
    }

    public QB_Sub relatedFields(String relationshipPath, List<sObjectField> fields) {
        qbs.fields.retrive(relationshipPath, fields);
        return this;
    }

    // Where

    public QB_Sub whereAre(QB_ConditionsGroup conditions) {
        // conditions.bindWith(qbb);
        // qb.conditions = conditions;
        return this;
    }

    // Build

    public String build() {
        return qbs.build();
    }
}
