public class QB_For extends QB_QueryClause {

    private enum ForStatements {
        FOR_REFERENCE,
        FOR_VIEW,
        FOR_UPDATE,
        ALL_ROWS
    }

    private ForStatements forStatement = ForStatements.ALL_ROWS;

    public void setForReference() {
        this.forStatement = ForStatements.FOR_REFERENCE;
    }

    public void setForView() {
        this.forStatement = ForStatements.FOR_VIEW;
    }

    public void setForUpdate() {
        this.forStatement = ForStatements.FOR_UPDATE;
    }

    public void setAllRows() {
        this.forStatement = ForStatements.ALL_ROWS;
    }

    public override String build() {
        return this.forStatement.name().replace('_', ' ') + ' \n';
    }

    public override Integer getPosition() {
        return 11;
    }
}
