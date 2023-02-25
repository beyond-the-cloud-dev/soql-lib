public inherited sharing class QBS implements QB_QueryClause {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public QBS(String ofObject) {
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

    public QBC.QGroupBy groupBy {
        get {
            if (clauses[3] == null) {
                clauses.set(3, new QBC.QGroupBy());
            }
            return (QBC.QGroupBy) clauses[3];
        }
    }

    public QBC.QOrderBy orderBy {
        get {
            if (clauses[4] == null) {
                clauses.set(4, new QBC.QOrderBy());
            }
            return (QBC.QOrderBy) clauses[4];
        }
    }

    public QBC.QLimit soqlLimit {
        get {
            if (clauses[5] == null) {
                clauses.set(5, new QBC.QLimit());
            }
            return (QBC.QLimit) clauses[5];
        }
    }

    public QBC.QOffset soqlOffset {
        get {
            if (clauses[6] == null) {
                clauses.set(6, new QBC.QOffset());
            }
            return (QBC.QOffset) clauses[6];
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
