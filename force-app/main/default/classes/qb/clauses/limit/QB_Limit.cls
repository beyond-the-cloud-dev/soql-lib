public class QB_Limit implements QB_QueryClause {
    private Integer soqlLimit;

    public QB_Limit(Integer soqlLimit) {
        soqlLimit = soqlLimit;
    }

    public String build() {
        return 'LIMIT ' + this.soqlLimit;
    }
}
