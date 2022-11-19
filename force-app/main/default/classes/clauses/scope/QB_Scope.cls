public class QB_Scope extends QB_QueryClause {
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

    public QB_Scope withDelegated() {
        return this.setScope(FilterScope.DELEGATED);
    }

    public QB_Scope withMine() {
        return this.setScope(FilterScope.MINE);
    }

    public QB_Scope withMineAndMyGroups() {
        return this.setScope(FilterScope.MINE_AND_MY_GROUPS);
    }

    public QB_Scope withMyTerritory() {
        return this.setScope(FilterScope.MY_TERRITORY);
    }

    public QB_Scope withMyTeamTerritory() {
        return this.setScope(FilterScope.MY_TEAM_TERRITORY);
    }

    public QB_Scope withTeam() {
        return this.setScope(FilterScope.TEAM);
    }

    private QB_Scope setScope(FilterScope scope) {
        this.scope = scope;
        return this;
    }

    public override String build() {
        return 'USING SCOPE ' + this.scope.name();
    }
}
