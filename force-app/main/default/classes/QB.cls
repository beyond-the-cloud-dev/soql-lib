public inherited sharing virtual class QB {
    private List<QB_QueryClause> clauses = new QB_QueryClause[11];

    public QB(sObjectType fromObject) {
        // this.queryClauses.set(0, new QB_Fields());
        // this.queryClauses.set(2, new QB_From(fromObject));
        // this.queryClauses.set(5, new QB_WithSecurityEnforced(fromObject)); // clause is only supported on top-level queries
    }

    public void fields() {
        this.clauses.set(0, null);
    }
}
