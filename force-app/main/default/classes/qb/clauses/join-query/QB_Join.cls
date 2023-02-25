public with sharing class QB_Join implements QB_QueryClause {
    private QB soqlBuilder;

    public QB_Join(String fromObject) {
        this.soqlBuilder = new QB(fromObject);
        this.soqlBuilder.withoutSecurityEnforced();
    }

    // Fields

    public QB_Join field(sObjectField field) {
        this.soqlBuilder.qbFields().add(new List<sObjectField>{ field });
        return this;
    }

    // Where

    public QB_Join condition(QB_ConditionClause conditionClause) {
        this.soqlBuilder.qbConditions().condition(conditionClause);
        return this;
    }

    public QB_Join conditionsOrder(String conditionsOrder) {
        this.soqlBuilder.qbConditions().conditionsOrder(conditionsOrder);
        return this;
    }

    // Helper

    public String build(QB_QueryExecutor executor) {
        return this.soqlBuilder.build(executor);
    }
}
