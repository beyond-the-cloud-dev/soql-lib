@isTest
public class QB_ScopeTest {

    @isTest
    static void delegatedScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).delegatedScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE DELEGATED'), 'Query should contains USING SCOPE DELEGATED');
    }

    @isTest
    static void mineScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).mineScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MINE'), 'Query should contains USING SCOPE MINE');
    }

    @isTest
    static void mineAndMyGroupsScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).mineAndMyGroupsScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MINE_AND_MY_GROUPS'), 'Query should contains USING SCOPE MINE_AND_MY_GROUPS');
    }

    @isTest
    static void myTerritoryScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).myTerritoryScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MY_TERRITORY'), 'Query should contains USING SCOPE MY_TERRITORY');
    }

    @isTest
    static void MyTeamTerritoryScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).MyTeamTerritoryScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE MY_TEAM_TERRITORY'), 'Query should contains USING SCOPE MY_TEAM_TERRITORY');
    }

    @isTest
    static void TeamScope() {
        Test.startTest();
        String query = new QB(Account.sObjectType).TeamScope().build();
        Test.stopTest();

        Assert.isTrue(query.contains('USING SCOPE TEAM'), 'Query should contains USING SCOPE TEAM');
    }
}
