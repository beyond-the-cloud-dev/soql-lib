public class QB_Condition implements QB_ConditionClause {
    private String field;
    private String comperator;
    private Object value;
    // private QB_Join joinQuery;

    public QB_Condition id() {
        return field('Id');
    }

    public QB_Condition recordTypeDeveloperName() {
        return field('RecordType.DeveloperName');
    }

    public QB_Condition field(Schema.SObjectField field) {
        return field(field.getDescribe().getName());
    }

    public QB_Condition relationship(String relationshipPath, Schema.SObjectField field) {
        return field(relationshipPath + '.' + field.getDescribe().getName());
    }

    private QB_Condition field(String field) {
        this.field = field;
        return this;
    }

    public QB_Condition isNull() {
        return this.equal(null);
    }

    public QB_Condition isNotNull() {
        return this.notEqual(null);
    }

    public QB_Condition equal(Object value) {
        return this.set('=', value);
    }

    public QB_Condition notEqual(Object fieldValue) {
        return this.set('!=', value);
    }

    public QB_Condition lessThan(Object value) {
        return this.set('<', value);
    }

    public QB_Condition greaterThan(Object fieldValue) {
        return this.set('>', value);
    }

    public QB_Condition lessThanOrEqual(Object fieldValue) {
        return this.set('<=', value);
    }

    public QB_Condition greaterThanOrEqual(Object fieldValue) {
        return this.set('>=', value);
    }

    public QB_Condition likeAnyBoth(String fieldValue) {
        return this.set('LIKE', '%' + String.escapeSingleQuotes(fieldValue.trim()) + '%');
    }

    public QB_Condition likeAnyLeft(String fieldValue) {
        return this.set('LIKE', '%' + String.escapeSingleQuotes(fieldValue.trim()));
    }

    public QB_Condition likeAnyRight(String fieldValue) {
        return this.set('LIKE', String.escapeSingleQuotes(fieldValue.trim()) + '%');
    }

    public QB_Condition inCollection(List<Object> inList) {
        return this.set('IN', inList);
    }

    public QB_Condition notIn(List<Object> inList) {
        return this.set('NOT IN', inList);
    }

    private QB_Condition set(String comperator, Object value) {
        this.value = value;
        this.comperator = comperator;
        return this;
    }

    // public QB_Condition inCollection(QB_Join joinQuery) {
    //     return this.set('IN', joinQuery);
    // }

    // public QB_Condition notIn(QB_Join joinQuery) {
    //     return this.set('NOT IN', joinQuery);
    // }

    // private QB_Condition set(String comperator, QB_Join joinQuery) {
    //     this.joinQuery = joinQuery;
    //     this.comperator = comperator;
    //     return this;
    // }

    public String build(QBB qbb) {
        // if (this.joinQuery != null) {
        //     return this.field + ' ' + this.comperator + ' (' + joinQuery.build(executor) + ')';
        // }

        return field + ' ' + comperator + ' :' + qbb.bind(value);
    }
}
