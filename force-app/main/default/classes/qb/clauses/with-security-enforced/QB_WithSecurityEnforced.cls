public class QB_WithSecurityEnforced implements QB_QueryClause {
    private sObjectType objectType = null;

    public QB_WithSecurityEnforced(sObjectType objectType) {
        this.objectType = objectType;
    }

    public String build(QB_QueryExecutor executor) {
        if (!this.objectType.getDescribe().isAccessible()) {
            return 'Permission to access an ' + this.objectType.getDescribe().getName() + ' denied.';
            // throw error;
        }
        return 'WITH SECURITY_ENFORCED';
    }
}
