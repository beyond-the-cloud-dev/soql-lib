public class QB_Limit extends QB_QueryClause {

    private Integer soqlLimit;

    public void set(Integer soqlLimit) {
        this.soqlLimit = soqlLimit;
    }

    public override String build() {
        return 'LIMIT ' + this.soqlLimit;
    }

    public override String validate() {
        if (this.soqlLimit < 1 || this.soqlLimit > 50000) {
            return 'Limit outside range. Limit should be between 1 - 50000. \n';
        }
        return '';
    }
}
