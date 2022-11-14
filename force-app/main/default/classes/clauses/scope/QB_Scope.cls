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

    public void withDelegated() {
        this.scope = FilterScope.DELEGATED;
    }

    public void withMine() {
        this.scope = FilterScope.MINE;
    }

    public void withMineAndMyGroups() {
        this.scope = FilterScope.MINE_AND_MY_GROUPS;
    }

    public void withMyTerritory() {
        this.scope = FilterScope.MY_TERRITORY;
    }

    public void withMyTeamTerritory() {
        this.scope = FilterScope.MY_TEAM_TERRITORY;
    }

    public void withTeam() {
        this.scope = FilterScope.TEAM;
    }

    public override String build() {
        return 'USING SCOPE ' + this.scope.name();
    }

    public override Integer getPosition() {
        return 4;
    }
}
