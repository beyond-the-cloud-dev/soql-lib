@isTest
public class QB_OrderByTest {

    @isTest
    static void withAscOrderSObjectField() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withAscOrder(Account.Name).build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name ASC'), 'Query should contains ORDER BY Name ASC');
    }

    @isTest
    static void withAscOrderString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withAscOrder('Name').build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name ASC'), 'Query should contains ORDER BY Name ASC');
    }

    @isTest
    static void withDescOrderSObjectField() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withDescOrder(Account.Name).build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name DESC'), 'Query should contains ORDER BY Name DESC');
    }

    @isTest
    static void withDescOrderString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withDescOrder('Name').build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name DESC'), 'Query should contains ORDER BY Name DESC');
    }
}
