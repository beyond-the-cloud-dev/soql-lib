public class QB_Scope extends QB_QueryClause {

    public enum FilterScope { // https://developer.salesforce.com/docs/atlas.en-us.236.0.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm
        DELEGATED,
        EVERYTHING,
        MINE,
        MINE_AND_MY_GROUPS,
        MY_TERRITORY,
        MY_TEAM_TERRITORY,
        TEAM
    }

    private FilterScope scope = FilterScope.EVERYTHING;

    public QB_Scope(QB_Scope.FilterScope scope) {
        this.scope = scope;
    }

    public override String build() {
        return 'USING SCOPE ' + this.scope.name() + ' \n';
    }

    public override Integer getPosition() {
        return 11;
    }
}
