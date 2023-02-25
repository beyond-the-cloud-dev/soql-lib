public inherited sharing class QBJ implements QB_QueryClause {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public QBJ(sObjectType ofObject) {
        clauses.set(0, new QBC.QFields());
        clauses.set(1, new QBC.QFrom(ofObject));
    }

    public QBC.QFields fields {
        get {
            return (QBC.QFields) clauses[0];
        }
    }

    public QB_ConditionsGroup conditions {
        get {
            return (QB_ConditionsGroup) clauses[2];
        }
        set {
            clauses.set(2, value);
        }
    }

    public String build() {
        List<String> soqlParts = new List<String>();

        for (QB_QueryClause clause : clauses) {
            if (clause == null) {
                continue;
            }
            soqlParts.add(clause.build());
        }

        return String.join(new List<String>(soqlParts), ' ');
    }
}
