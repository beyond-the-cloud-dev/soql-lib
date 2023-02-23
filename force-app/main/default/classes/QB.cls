public inherited sharing class QB implements QB_QueryClause {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public QB(sObjectType ofObject) {
        clauses.set(0, new QBC.QFields());
        clauses.set(2, new QBC.QFrom(ofObject));
    }

    public QB_Fields fields {
        get {
            return (QB_Fields) clauses[0];
        }
    }

    // 1 - SUB-QUERY

    // 2 - FROM

    public QBC.QScope scope {
        get {
            if (clauses[3] == null) {
                clauses.set(3, new QBC.QScope());
            }
            return (QBC.QScope) clauses[3];
        }
    }

    // 4 - WHERE

    public QBC.QGroupBy groupBy {
        get {
            if (clauses[6] == null) {
                clauses.set(6, new QBC.QGroupBy());
            }
            return (QBC.QGroupBy) clauses[6];
        }
    }

    public QBC.QOrderBy orderBy {
        get {
            if (clauses[7] == null) {
                clauses.set(7, new QBC.QOrderBy());
            }
            return (QBC.QOrderBy) clauses[7];
        }
    }

    public QBC.QLimit soqlLimit {
        get {
            if (clauses[8] == null) {
                clauses.set(8, new QBC.QLimit());
            }
            return (QBC.QLimit) clauses[8];
        }
    }

    public QBC.QOffset soqlOffset {
        get {
            if (clauses[9] == null) {
                clauses.set(9, new QBC.QOffset());
            }
            return (QBC.QOffset) clauses[9];
        }
    }

    public QBC.QFor soqlFor {
        get {
            if (clauses[10] == null) {
                clauses.set(10, new QBC.QFor());
            }
            return (QBC.QFor) clauses[10];
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
