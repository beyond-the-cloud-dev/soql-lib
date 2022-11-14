public class QB_GroupBy extends QB_QueryClause {

    private Set<String> groupByFields = new Set<String>();

    public QB_GroupBy(List<sObjectField> fields) {
        for (sObjectField field : fields) {
            this.groupByFields.add(field.getDescribe().getName());
        }
    }

    public QB_GroupBy(sObjectField field) {
        this.groupByFields.add(field.getDescribe().getName());
    }

    public override String build() {
        return 'GROUP BY ' + String.join(new List<String>(this.groupByFields), ', ');
    }

    public override Integer getPosition() {
        return 7;
    }
}
