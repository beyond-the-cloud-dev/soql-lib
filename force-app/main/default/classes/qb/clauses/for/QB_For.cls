public class QB_For implements QB_QueryClause {
    private enum ForStatements {
        FOR_REFERENCE,
        FOR_VIEW,
        FOR_UPDATE,
        ALL_ROWS
    }

    private ForStatements forStatement = ForStatements.ALL_ROWS;

    public void referece() {
        forStatement(ForStatements.FOR_REFERENCE);
    }

    public void view() {
        forStatement(ForStatements.FOR_VIEW);
    }

    public void forUpdate() {
        forStatement(ForStatements.FOR_UPDATE);
    }

    public void allRows() {
        forStatement(ForStatements.ALL_ROWS);
    }

    private void forStatement(ForStatements forStatement) {
        forStatement = forStatement;
    }

    public String build() {
        return forStatement.name().replace('_', ' ');
    }
}
