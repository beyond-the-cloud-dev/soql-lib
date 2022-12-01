public class QB_Offset implements QB_QueryClause {
    private Integer soqlOffset;

    public void set(Integer soqlOffset) {
        this.soqlOffset = soqlOffset;
    }

    public String build(QB_QueryExecutor executor) {
        return 'OFFSET ' + this.soqlOffset;
    }
}
