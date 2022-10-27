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

    public void setDelegated() {
        this.scope = FilterScope.DELEGATED;
    }

    public void setMine() {
        this.scope = FilterScope.MINE;
    }

    public void setMineAndMyGroups() {
        this.scope = FilterScope.MINE_AND_MY_GROUPS;
    }

    public void setMyTerritory() {
        this.scope = FilterScope.MY_TERRITORY;
    }

    public void setMyTeamTerritory() {
        this.scope = FilterScope.MY_TEAM_TERRITORY;
    }

    public void setTeam() {
        this.scope = FilterScope.TEAM;
    }

    public override String build() {
        return 'USING SCOPE ' + this.scope.name();
    }

    public override Integer getPosition() {
        return 11;
    }
}
