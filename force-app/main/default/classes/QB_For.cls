public class QB_For extends QB_QueryClause {

    private String forStatement;

    public void setForReference() {
        this.forStatement = 'FOR REFERENCE';
    }

    public void setForView() {
        this.forStatement = 'FOR VIEW';
    }

    public void setForUpdate() {
        this.forStatement = 'FOR UPDATE';
    }

    public void setAllRows() {
        this.forStatement = 'ALL ROWS';
    }

    public override String build() {
        return this.forStatement + ' \n';
    }

    public override Integer getPosition() {
        return 11;
    }
}
