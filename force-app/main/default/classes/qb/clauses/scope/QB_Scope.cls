public class QB_Scope implements QB_QueryClause {
    private enum FilterScope { // https://developer.salesforce.com/docs/atlas.en-us.236.0.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm
        DELEGATED,
        EVERYTHING,
        MINE,
        MINE_AND_MY_GROUPS,
        MY_TERRITORY,
        MY_TEAM_TERRITORY,
        TEAM
    }

    private FilterScope scope = FilterScope.EVERYTHING;

    public void delegated() {
        scope(FilterScope.DELEGATED);
    }

    public void mine() {
        scope(FilterScope.MINE);
    }

    public void mineAndMyGroups() {
        scope(FilterScope.MINE_AND_MY_GROUPS);
    }

    public void myTerritory() {
        scope(FilterScope.MY_TERRITORY);
    }

    public void myTeamTerritory() {
        scope(FilterScope.MY_TEAM_TERRITORY);
    }

    public void team() {
        scope(FilterScope.TEAM);
    }

    private void scope(FilterScope scope) {
        this.scope = scope;
    }

    public String build() {
        return 'USING SCOPE ' + this.scope.name();
    }
}
