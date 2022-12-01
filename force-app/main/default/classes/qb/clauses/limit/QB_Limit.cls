public class QB_Limit implements QB_QueryClause {
    private Integer soqlLimit;

    public void set(Integer soqlLimit) {
        this.soqlLimit = soqlLimit;
    }

    public String build(QB_QueryExecutor executor) {
        return 'LIMIT ' + this.soqlLimit;
    }
}
