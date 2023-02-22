public class QS {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        clauses.set(2, new QB_From(ofObject));
    }

    public static QB_Fields Fields {
        get {
            return new QB_Fields();
        }
        private set;
    }

    public static QB_Scope Scope {
        get {
            return new QB_Scope();
        }
        private set;
    }

    public QS fields(QB_Fields fields) {
        clauses.set(0, fields);
        return this;
    }

    public QS subquery() {
        return this;
    }

    public QS scope(QB_Scope scope) {
        clauses.set(3, scope);
        return this;
    }

    public QS setLimit(Integer queryLimit) {
        clauses.set(8, new QB_Limit(queryLimit));
        return this;
    }

    public QS sharing() {
        return this;
    }
}


// QS.of(Account.sObjectType)
//     .fields(QS.Fields.add(Account.Name))
//     .scope(QS.Scope.mineAndMyGroups())
//     .setLimit(10);
