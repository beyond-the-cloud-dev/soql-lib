public inherited sharing class QB implements QB_QueryClause {
    private List<QB_QueryClause> clauses = new QB_QueryClause[10];

    public QB(sObjectType ofObject) {
        this(ofObject.getDescribe().getName());
    }

    public QB(String ofObject) {
        clauses.set(0, new QBC.QFields());
        clauses.set(2, new QBC.QFrom(ofObject));
    }

    public QBC.QFields fields {
        get {
            return (QBC.QFields) clauses[0];
        }
    }

    public QBC.QB_SubQueries subQueries {
        get {
            if (clauses[1] == null) {
                clauses.set(1, new QBC.QB_SubQueries());
            }
            return (QBC.QB_SubQueries) clauses[1];
        }
    }

    public QBC.QScope scope {
        get {
            if (clauses[3] == null) {
                clauses.set(3, new QBC.QScope());
            }
            return (QBC.QScope) clauses[3];
        }
    }

    public QB_ConditionsGroup conditions {
        get {
            return (QB_ConditionsGroup) clauses[4];
        }
        set {
            clauses.set(4, value);
        }
    }

    public QBC.QGroupBy groupBy {
        get {
            if (clauses[5] == null) {
                clauses.set(5, new QBC.QGroupBy());
            }
            return (QBC.QGroupBy) clauses[5];
        }
    }

    public QBC.QOrderBy orderBy {
        get {
            if (clauses[6] == null) {
                clauses.set(6, new QBC.QOrderBy());
            }
            return (QBC.QOrderBy) clauses[6];
        }
    }

    public QBC.QLimit soqlLimit {
        get {
            if (clauses[7] == null) {
                clauses.set(7, new QBC.QLimit());
            }
            return (QBC.QLimit) clauses[7];
        }
    }

    public QBC.QOffset soqlOffset {
        get {
            if (clauses[8] == null) {
                clauses.set(8, new QBC.QOffset());
            }
            return (QBC.QOffset) clauses[8];
        }
    }

    public QBC.QFor soqlFor {
        get {
            if (clauses[9] == null) {
                clauses.set(9, new QBC.QFor());
            }
            return (QBC.QFor) clauses[9];
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
