public inherited sharing virtual class QB implements QB_QueryClause {
    private List<QB_QueryClause> queryClauses = new QB_QueryClause[11];

    public QB(sObjectType fromObject) {
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(fromObject));
        this.queryClauses.set(5, new QB_WithSecurityEnforced(fromObject)); // clause is only supported on top-level queries
    }

    public QB(String fromObject) {
        this.queryClauses.set(0, new QB_Fields());
        this.queryClauses.set(2, new QB_From(fromObject));
    }

    // Fields

    public QB_Fields qbFields() {
        return (QB_Fields) get(0, QB_Fields.class);
    }

    // SubQuery

    public QB_SubQueries qbSubQuery() {
        return (QB_SubQueries) get(1, QB_SubQueries.class);
    }

    // Scope

    public QB_Scope qbScope() {
        return (QB_Scope) get(3, QB_Scope.class);
    }

    // Where

    public QB_ConditionsGroup qbConditions() {
        return (QB_ConditionsGroup) get(4, QB_ConditionsGroup.class);
    }

    // Security

    public QB withoutSecurityEnforced() {
        this.queryClauses.set(5, null);
        return this;
    }

    // Group By

    public QB_GroupBy qbGroupBy() {
        return (QB_GroupBy) get(6, QB_GroupBy.class);
    }

    // Order By

    public QB_OrderBy qbOrderBy() {
        return (QB_OrderBy) get(7, QB_OrderBy.class);
    }

    // Limit

    public QB_Limit qbLimit() {
        return (QB_Limit) get(8, QB_Limit.class);
    }

    // Offset

    public QB_Offset qbOffset() {
        return (QB_Offset) get(9, QB_Offset.class);
    }

    // For

    public QB_For qbFor() {
        return (QB_For) get(10, QB_For.class);
    }

    // Preview

    // public QB preview() {
    //     this.queryExecutor.withPreview();
    //     return this;
    // }

    // Helpers

    public QB_QueryClause get(Integer index, System.Type queryClauseClass) {
        QB_QueryClause qc = this.queryClauses.get(index);
        if (qc == null) {
            qc = (QB_QueryClause) queryClauseClass.newInstance();
            this.queryClauses.set(index, qc);
        }
        return qc;
    }

    public String build(QB_QueryExecutor executor) {
        List<String> clauses = new List<String>();

        for (QB_QueryClause clause : this.queryClauses) {
            if (clause == null) {
                continue;
            }
            clauses.add(clause.build(executor));
        }

        return String.join(new List<String>(clauses), ' ');
    }
}
