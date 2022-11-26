public with sharing class QB_Sub extends QB_QueryClause {
    protected List<QB_QueryClause> queryClauses = new QB_QueryClause[8];
    protected QB_QueryExecutor queryExecutor = null;

    public QB_Sub(String fromObject) {
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(1, new QB_From(fromObject));

        this.queryExecutor = new QB_QueryExecutor();
    }

    // Fields

    public QB_Sub fields(List<sObjectField> fields) {
        this.qbFields().add(fields);
        return this;
    }

    public QB_Sub fields(String commaSeparatedFields) {
        this.qbFields().add(commaSeparatedFields);
        return this;
    }

    public QB_Sub relationship(String relationshipName, List<sObjectField> fields) {
        this.qbFields().add(relationshipName, fields);
        return this;
    }

    private QB_Fields qbFields() {
        return (QB_Fields) get(0, QB_Fields.class);
    }

    // Where

    public QB_Sub condition(QB_ConditionClause conditionClause) {
        this.qbConditions().add(conditionClause);
        return this;
    }

    public QB_Sub conditionsOrder(String conditionsOrder) {
        this.qbConditions().order(conditionsOrder);
        return this;
    }

    private QB_ConditionsGroup qbConditions() {
        return (QB_ConditionsGroup) get(2, QB_ConditionsGroup.class);
    }

    // Group By

    public QB_Sub groupBy(sObjectField field) {
        this.qbGroupBy().add(field);
        return this;
    }

    public QB_Sub groupBy(List<sObjectField> fields) {
        this.qbGroupBy().add(fields);
        return this;
    }

    private QB_GroupBy qbGroupBy() {
        return (QB_GroupBy) get(3, QB_GroupBy.class);
    }

    // Order By

    public QB_Sub ascOrder(sObjectField field) {
        this.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB_Sub ascOrder(String field) {
        this.qbOrderBy().setField(field).setAscOrder();
        return this;
    }

    public QB_Sub descOrder(sObjectField field) {
        this.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB_Sub descOrder(String field) {
        this.qbOrderBy().setField(field).setDescOrder();
        return this;
    }

    public QB_Sub nullFirst() {
        this.qbOrderBy().setNullsFirstOrder();
        return this;
    }

    public QB_Sub nullLast() {
        this.qbOrderBy().setNullsLastOrder();
        return this;
    }

    private QB_OrderBy qbOrderBy() {
        return (QB_OrderBy) get(4, QB_OrderBy.class);
    }

    // Limit

    public QB_Sub setLimit(Integer soqlLimit) {
        this.qbLimit().set(soqlLimit);
        return this;
    }

    private QB_Limit qbLimit() {
        return (QB_Limit) get(5, QB_Limit.class);
    }

    // Offset

    public QB_Sub setOffset(Integer soqlOffset) {
        this.qbOffset().set(soqlOffset);
        return this;
    }

    private QB_Offset qbOffset() {
        return (QB_Offset) get(6, QB_Offset.class);
    }

    // For

    public QB_Sub forReference() {
        this.qbFor().withForReferece();
        return this;
    }

    public QB_Sub forView() {
        this.qbFor().withForView();
        return this;
    }

    private QB_For qbFor() {
        return (QB_For) get(7, QB_For.class);
    }

    // Helpers

    public QB_QueryClause get(Integer index, System.Type queryClauseClass) {
        QB_QueryClause qc = this.queryClauses.get(index);
        if (qc == null) {
            qc = (QB_QueryClause) queryClauseClass.newInstance();
            this.queryClauses.set(index, qc);
        }
        return qc;
    }

    public override String build() {
        this.validate();

        List<String> clauses = new List<String>();

        for (QB_QueryClause clause : this.queryClauses) {
            if (clause == null) {
                continue;
            }
            clauses.add(clause.build());
        }

        return String.join(new List<String>(clauses), ' ');
    }

    public override String validate() {
        String queryErrors = '';

        for (QB_QueryClause clause : this.queryClauses) {
            if (clause == null) {
                continue;
            }
            queryErrors += clause.validate();
        }

        return queryErrors;
    }
}
