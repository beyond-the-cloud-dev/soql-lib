public class QB_WithSecurityEnforced extends QB_QueryClause {

    public override String build() {
        return 'WITH SECURITY_ENFORCED';
    }
}
