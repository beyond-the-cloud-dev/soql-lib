@isTest
public class QB_ForTest {
    @isTest
    static void forReference() {
        Test.startTest();
        String query = new QB(Account.sObjectType).forReference().build();
        Test.stopTest();

        Assert.isTrue(query.contains('FOR REFERENCE'), 'Query should contains FOR REFERENCE');
    }

    @isTest
    static void forView() {
        Test.startTest();
        String query = new QB(Account.sObjectType).forView().build();
        Test.stopTest();

        Assert.isTrue(query.contains('FOR VIEW'), 'Query should contains FOR VIEW');
    }

    @isTest
    static void forUpdate() {
        Test.startTest();
        String query = new QB(Account.sObjectType).forUpdate().build();
        Test.stopTest();

        Assert.isTrue(query.contains('FOR UPDATE'), 'Query should contains FOR UPDATE');
    }

    @isTest
    static void allRows() {
        Test.startTest();
        String query = new QB(Account.sObjectType).allRows().build();
        Test.stopTest();

        Assert.isTrue(query.contains('ALL ROWS'), 'Query should contains ALL ROWS');
    }
}
