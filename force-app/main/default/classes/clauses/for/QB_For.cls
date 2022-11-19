public class QB_For extends QB_QueryClause {

    private enum ForStatements {
        FOR_REFERENCE,
        FOR_VIEW,
        FOR_UPDATE,
        ALL_ROWS
    }

    private ForStatements forStatement = ForStatements.ALL_ROWS;

    public QB_For withForReferece() {
        return this.setForStatement(ForStatements.FOR_REFERENCE);
    }

    public QB_For withForView() {
        return this.setForStatement(ForStatements.FOR_VIEW);
    }

    public QB_For withForUpdate() {
        return this.setForStatement(ForStatements.FOR_UPDATE);
    }

    public QB_For withAllRows() {
        return this.setForStatement(ForStatements.ALL_ROWS);
    }

    private QB_For setForStatement(ForStatements forStatement) {
        this.forStatement = forStatement;
        return this;
    }

    public override String build() {
        return this.forStatement.name().replace('_', ' ');
    }

    public override Integer getPosition() {
        return 11;
    }
}
