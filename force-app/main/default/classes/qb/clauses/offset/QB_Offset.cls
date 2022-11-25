public class QB_Offset extends QB_QueryClause {

    private Integer soqlOffset;

    public void set(Integer soqlOffset) {
        this.soqlOffset = soqlOffset;
    }

    public override String build() {
        return 'OFFSET ' + this.soqlOffset;
    }

    public override String validate() {
        if (this.soqlOffset < 1 || this.soqlOffset > 2000) {
            return 'Offset outside range. Offset should be between 0 - 2000. \n';
        }
        return '';
    }
}
