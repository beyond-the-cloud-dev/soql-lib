public class QB_GroupBy extends QB_QueryClause {

    private Set<String> groupByFields = new Set<String>();

    public void add(List<sObjectField> fields) {
        for (sObjectField field : fields) {
            this.add(field);
        }
    }

    public void add(sObjectField field) {
        this.groupByFields.add(field.getDescribe().getName());
    }

    public override String build() {
        return 'GROUP BY ' + String.join(new List<String>(this.groupByFields), ', ');
    }
}
