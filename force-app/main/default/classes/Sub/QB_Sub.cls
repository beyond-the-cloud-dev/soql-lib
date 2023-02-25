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

    // Build

    public String build() {
        return qb.build();
    }
}
