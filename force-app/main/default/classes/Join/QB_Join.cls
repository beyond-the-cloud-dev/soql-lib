public with sharing class QB_Join implements QB_QueryClause {
    private QBJ qbj;
    private QBB qbb;

    public QB_Join of(sObjectType ofObject) {
        qbj = new QBJ(ofObject);
        return this;
    }

    public QB_Join(QBB qbb) {
        this.qbb = qbb;
    }
    // Fields

    public QB_Join field(sObjectField field) {
        qbj.fields.retrive(new List<sObjectField>{ field });
        return this;
    }

    // Where

    public QB_Join whereAre(QB_ConditionsGroup conditions) {
        qbj.conditions = conditions;
        return this;
    }

    // Helper

    public String build() {
        return qbj.build();
    }
}
