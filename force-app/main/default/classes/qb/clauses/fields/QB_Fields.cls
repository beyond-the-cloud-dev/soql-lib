public class QB_Fields extends QB_QueryClause {

    private Set<String> fieldsToQuery = new Set<String>{ 'Id' };

    public QB_Fields() {}

    public QB_Fields(String commaSeparatedFields) {
        this.addFields(commaSeparatedFields);
    }

    public QB_Fields(List<sObjectField> fields) {
        this.addFields(fields);
    }

    public QB_Fields addFields(String commaSeparatedFields) {
        this.fieldsToQuery.addAll(commaSeparatedFields.deleteWhitespace().split(','));
        return this;
    }

    public QB_Fields addFields(List<sObjectField> fields) {
        for (sObjectField field : fields) {
            this.fieldsToQuery.add(field.getDescribe().getName());
        }
        return this;
    }

    public override String build() {
        return 'SELECT ' + String.join(new List<String>(this.fieldsToQuery), ', ');
    }
}
