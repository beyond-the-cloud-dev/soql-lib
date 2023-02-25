public with sharing class QB_Sub implements QB_QueryClause {
    private QB soqlBuilder;

    public QB_Sub(String fromObject) {
        this.soqlBuilder = new QB(fromObject);
        this.soqlBuilder.withoutSecurityEnforced();
    }

    // Fields

    public QB_Sub fields(List<sObjectField> fields) {
        this.soqlBuilder.qbFields().add(fields);
        return this;
    }

    public QB_Sub fields(String commaSeparatedFields) {
        this.soqlBuilder.qbFields().add(commaSeparatedFields);
        return this;
    }

    public QB_Sub relationship(String relationshipName, List<sObjectField> fields) {
        this.soqlBuilder.qbFields().add(relationshipName, fields);
        return this;
    }

    // Where

    public QB_Sub condition(QB_ConditionClause conditionClause) {
        this.soqlBuilder.qbConditions().condition(conditionClause);
        return this;
    }

    public QB_Sub conditionsOrder(String conditionsOrder) {
        this.soqlBuilder.qbConditions().conditionsOrder(conditionsOrder);
        return this;
    }

    // Group By

    public QB_Sub groupBy(sObjectField field) {
        this.soqlBuilder.qbGroupBy().add(field);
        return this;
    }

    public QB_Sub groupBy(List<sObjectField> fields) {
        this.soqlBuilder.qbGroupBy().add(fields);
        return this;
    }

    // Order By

    public QB_Sub ascOrder(sObjectField field) {
        this.soqlBuilder.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB_Sub ascOrder(String field) {
        this.soqlBuilder.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB_Sub descOrder(sObjectField field) {
        this.soqlBuilder.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB_Sub descOrder(String field) {
        this.soqlBuilder.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB_Sub nullFirst() {
        this.soqlBuilder.qbOrderBy().setNullsFirstOrder();
        return this;
    }

    public QB_Sub nullLast() {
        this.soqlBuilder.qbOrderBy().setNullsLastOrder();
        return this;
    }

    // Limit

    public QB_Sub setLimit(Integer soqlLimit) {
        this.soqlBuilder.qbLimit().set(soqlLimit);
        return this;
    }

    // Offset

    public QB_Sub setOffset(Integer soqlOffset) {
        this.soqlBuilder.qbOffset().set(soqlOffset);
        return this;
    }

    // For

    public QB_Sub forReference() {
        this.soqlBuilder.qbFor().withForReferece();
        return this;
    }

    public QB_Sub forView() {
        this.soqlBuilder.qbFor().withForView();
        return this;
    }

    public String build(QB_QueryExecutor executor) {
        return this.soqlBuilder.build(executor);
    }
}
