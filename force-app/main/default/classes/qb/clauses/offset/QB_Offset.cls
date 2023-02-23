public class QB_Offset implements QB_QueryClause {
    private Integer soqlOffset;

    public QB_Offset(Integer soqlOffset) {
        soqlOffset = soqlOffset;
    }

    public String build() {
        return 'OFFSET ' + soqlOffset;
    }
}
