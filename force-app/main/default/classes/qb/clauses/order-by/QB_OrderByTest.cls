@isTest
public class QB_OrderByTest {

    @isTest
    static void ascOrderSObjectField() {
        Test.startTest();
        String query = new QB(Account.sObjectType).ascOrder(Account.Name).build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name ASC'), 'Query should contains ORDER BY Name ASC');
    }

    @isTest
    static void ascOrderString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).ascOrder('Name').build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name ASC'), 'Query should contains ORDER BY Name ASC');
    }

    @isTest
    static void descOrderSObjectField() {
        Test.startTest();
        String query = new QB(Account.sObjectType).descOrder(Account.Name).build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name DESC'), 'Query should contains ORDER BY Name DESC');
    }

    @isTest
    static void descOrderString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).descOrder('Name').build();
        Test.stopTest();

        Assert.isTrue(query.contains('ORDER BY Name DESC'), 'Query should contains ORDER BY Name DESC');
    }
}
