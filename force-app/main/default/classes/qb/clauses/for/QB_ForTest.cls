@isTest
public class QB_ForTest {
    @isTest
    static void withForReference() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withForReference().build();
        Test.stopTest();

        Assert.isTrue(query.contains('FOR REFERENCE'), 'Query should contains FOR REFERENCE');
    }

    @isTest
    static void withForView() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withForView().build();
        Test.stopTest();

        Assert.isTrue(query.contains('FOR VIEW'), 'Query should contains FOR VIEW');
    }

    @isTest
    static void withForUpdate() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withForUpdate().build();
        Test.stopTest();

        Assert.isTrue(query.contains('FOR UPDATE'), 'Query should contains FOR UPDATE');
    }

    @isTest
    static void withAllRows() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withAllRows().build();
        Test.stopTest();

        Assert.isTrue(query.contains('ALL ROWS'), 'Query should contains ALL ROWS');
    }
}
Contact c = [SELECT Id FROM Contact WHERE Name = 'ss'];
Contact c = new QS_Contact().toObject();
