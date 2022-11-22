public class QB_WithSecurityEnforced extends QB_QueryClause {
    private sObjectType objectType = null;

    public QB_WithSecurityEnforced(sObjectType objectType) {
        this.objectType = objectType;
    }

    public override String build() {
        return 'WITH SECURITY_ENFORCED';
    }

    public override String validate() {
        if (!this.objectType.getDescribe().isAccessible()) {
            return 'Permission to access an ' + this.objectType.getDescribe().getName() + ' denied.';
        }
        return '';
    }
}
