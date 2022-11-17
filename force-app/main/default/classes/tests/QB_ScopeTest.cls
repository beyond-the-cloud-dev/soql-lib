@isTest
public class QB_ScopeTest {

    @isTest
    static void withDelegatedScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withDelegatedScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE DELEGATED'), 'Query should contains USING SCOPE DELEGATED');
    }

    @isTest
    static void withMineScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withMineScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MINE'), 'Query should contains USING SCOPE MINE');
    }

    @isTest
    static void withMineAndMyGroupsScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withMineAndMyGroupsScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MINE_AND_MY_GROUPS'), 'Query should contains USING SCOPE MINE_AND_MY_GROUPS');
    }

    @isTest
    static void withMyTerritoryScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withMyTerritoryScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MY_TERRITORY'), 'Query should contains USING SCOPE MY_TERRITORY');
    }

    @isTest
    static void withMyTeamTerritoryScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withMyTeamTerritoryScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MY_TEAM_TERRITORY'), 'Query should contains USING SCOPE MY_TEAM_TERRITORY');
    }

    @isTest
    static void withTeamScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withTeamScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE TEAM'), 'Query should contains USING SCOPE TEAM');
    }
}
