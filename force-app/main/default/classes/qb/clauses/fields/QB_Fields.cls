public class QB_Fields implements QB_QueryClause {
    private Set<String> fields = new Set<String>{ 'Id' };

    // public QB_Fields add(String commaSeparatedFields) {
    //     this.fieldsToQuery.addAll(commaSeparatedFields.deleteWhitespace().split(','));
    //     return this;
    // }

    // public QB_Fields add(List<sObjectField> fields) {
    //     for (sObjectField field : fields) {
    //         this.fieldsToQuery.add(field.getDescribe().getName());
    //     }
    //     return this;
    // }

    // public QB_Fields add(String relationshipName, List<sObjectField> fields) {
    //     for (sObjectField field : fields) {
    //         this.fieldsToQuery.add(relationshipName + '.' + field.getDescribe().getName());
    //     }
    //     return this;
    // }

    public QB_Fields add(sObjectField field) {
        fields.add(field.getDescribe().getName());
        return this;
    }

    public String build() {
        return 'SELECT ' + String.join(new List<String>(fields), ', ');
    }
}
