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
        this.scope = FilterScope.DELEGATED;
        return this;
    }

    public QB_Scope withMine() {
        this.scope = FilterScope.MINE;
        return this;
    }

    public QB_Scope withMineAndMyGroups() {
        this.scope = FilterScope.MINE_AND_MY_GROUPS;
        return this;
    }

    public QB_Scope withMyTerritory() {
        this.scope = FilterScope.MY_TERRITORY;
        return this;
    }

    public QB_Scope withMyTeamTerritory() {
        this.scope = FilterScope.MY_TEAM_TERRITORY;
        return this;
    }

    public QB_Scope withTeam() {
        this.scope = FilterScope.TEAM;
        return this;
    }

    public override String build() {
        return 'USING SCOPE ' + this.scope.name();
    }

    public override Integer getPosition() {
        return 4;
    }
}
