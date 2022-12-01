public class QB_Condition implements QB_ConditionClause {
    private String fieldName;
    private String comperator;

    private Object value;
    private QB_Join joinQuery;

    public QB_Condition() {
        this.fieldName = 'Id';
    }

    public QB_Condition(String relationshipName, Schema.SObjectField field) {
        this.fieldName = relationshipName + '.' + field.getDescribe().getName();
    }

    public QB_Condition(Schema.SObjectField field) {
        this.fieldName = field.getDescribe().getName();
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

    public QB_Condition inCollection(QB_Join joinQuery) {
        return this.set('IN', joinQuery);
    }

    public QB_Condition notIn(QB_Join joinQuery) {
        return this.set('NOT IN', joinQuery);
    }

    private QB_Condition set(String comperator, QB_Join joinQuery) {
        this.joinQuery = joinQuery;
        this.comperator = comperator;
        return this;
    }

    public String build(QB_QueryExecutor executor) {
        String condition = this.fieldName + ' ' + this.comperator + ' :';
        if (this.joinQuery != null) {
            return condition + joinQuery.build(executor);
        }
        return condition + executor.bindVariable(this.value);
    }
}
