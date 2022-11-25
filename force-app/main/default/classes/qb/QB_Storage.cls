public with sharing class QB_Storage {
    public List<QB_QueryClause> queryClauses = new QB_QueryClause[11];

    public QB_Storage(sObjectType fromObject) {
        this.set(0, new QB_Fields());
        this.set(2, new QB_From(fromObject));
        this.set(5, new QB_WithSecurityEnforced(fromObject)); // clause is only supported on top-level queries
    }

    public QB_Storage(String fromObject) {
        this.set(0, new QB_Fields());
        this.set(2, new QB_From(fromObject));
    }

    // Fields

    public QB_Fields qbFields() {
        return (QB_Fields) queryClauses.get(0);
    }

    // SubQuery

    public QB_SubQuery qbSubQuery() {
        QB_SubQuery qbSubQuery = (QB_SubQuery) queryClauses.get(1);
        if (qbSubQuery == null) {
            qbSubQuery = new QB_SubQuery();
            this.set(1, qbSubQuery);
        }
        return qbSubQuery;
    }

    // Scope

    public QB_Scope qbScope() {
        QB_Scope qbScope = (QB_Scope) queryClauses.get(3);
        if (qbScope == null) {
            qbScope = new QB_Scope();
            this.set(3, qbScope);
        }
        return qbScope;
    }

    // Where

    public QB_ConditionsGroup qbConditions() {
        QB_ConditionsGroup qbConditions = (QB_ConditionsGroup) queryClauses.get(4);
        if (qbConditions == null) {
            qbConditions = new QB_ConditionsGroup().top();
            this.set(4, qbConditions);
        }
        return qbConditions;
    }

    // Security

    public void removeSecurityEnforced() {
        this.set(5, null);
    }

    // Group By

    public QB_GroupBy qbGroupBy() {
        QB_GroupBy qbGroupBy = (QB_GroupBy) queryClauses.get(6);
        if (qbGroupBy == null) {
            qbGroupBy = new QB_GroupBy();
            this.set(6, qbGroupBy);
        }
        return qbGroupBy;
    }

    // Order By

    public QB_OrderBy qbOrderBy() {
        QB_OrderBy qbOrderBy = (QB_OrderBy) queryClauses.get(7);
        if (qbOrderBy == null) {
            qbOrderBy = new QB_OrderBy();
            this.set(7, qbOrderBy);
        }
        return qbOrderBy;
    }

    // Limit

    public QB_Limit qbLimit() {
        QB_Limit qbLimit = (QB_Limit) queryClauses.get(8);
        if (qbLimit == null) {
            qbLimit = new QB_Limit();
            this.set(8, qbLimit);
        }
        return qbLimit;
    }

    // Offset

    public QB_Offset qbOffset() {
        QB_Offset qbOffset = (QB_Offset) queryClauses.get(9);
        if (qbOffset == null) {
            qbOffset = new QB_Offset();
            this.set(9, qbOffset);
        }
        return qbOffset;
    }

    // For

    public QB_For qbFor() {
        QB_For qbFor = (QB_For) queryClauses.get(10);
        if (qbFor == null) {
            qbFor = new QB_For();
            this.set(9, qbFor);
        }
        return qbFor;
    }

    // Helper

    private void set(Integer index, QB_QueryClause queryClause) {
        this.queryClauses.set(index, queryClause);
    }
}
