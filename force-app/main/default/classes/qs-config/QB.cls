public inherited sharing class QB implements QB_Part {
    private List<QB_Part> clauses = new QB_Part[10];

    public QB(sObjectType ofObject) {
        this(ofObject.getDescribe().getName());
    }

    public QB(String ofObject) {
        clauses.set(0, new QB_Components.QFields());
        clauses.set(2, new QB_Components.QFrom(ofObject));
    }

    public QB_Components.QFields fields {
        get {
            return (QB_Components.QFields) clauses[0];
        }
    }

    public QB_Components.QB_SubQueries subQueries {
        get {
            if (clauses[1] == null) {
                clauses.set(1, new QB_Components.QB_SubQueries());
            }
            return (QB_Components.QB_SubQueries) clauses[1];
        }
    }

    public QB_Components.QScope scope {
        get {
            if (clauses[3] == null) {
                clauses.set(3, new QB_Components.QScope());
            }
            return (QB_Components.QScope) clauses[3];
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

    public QB_Components.QGroupBy groupBy {
        get {
            if (clauses[5] == null) {
                clauses.set(5, new QB_Components.QGroupBy());
            }
            return (QB_Components.QGroupBy) clauses[5];
        }
    }

    public QB_Components.QOrderBy orderBy {
        get {
            if (clauses[6] == null) {
                clauses.set(6, new QB_Components.QOrderBy());
            }
            return (QB_Components.QOrderBy) clauses[6];
        }
    }

    public QB_Components.QLimit soqlLimit {
        get {
            if (clauses[7] == null) {
                clauses.set(7, new QB_Components.QLimit());
            }
            return (QB_Components.QLimit) clauses[7];
        }
    }

    public QB_Components.QOffset soqlOffset {
        get {
            if (clauses[8] == null) {
                clauses.set(8, new QB_Components.QOffset());
            }
            return (QB_Components.QOffset) clauses[8];
        }
    }

    public QB_Components.QFor soqlFor {
        get {
            if (clauses[9] == null) {
                clauses.set(9, new QB_Components.QFor());
            }
            return (QB_Components.QFor) clauses[9];
        }
    }

    public String build() {
        List<String> soqlParts = new List<String>();

        for (QB_Part clause : clauses) {
            if (clause == null) {
                continue;
            }
            soqlParts.add(clause.build());
        }

        return String.join(new List<String>(soqlParts), ' ');
    }
}
