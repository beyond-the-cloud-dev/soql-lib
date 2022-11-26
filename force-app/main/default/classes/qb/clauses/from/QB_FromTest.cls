
@isTest
public class QB_FromTest {
    @isTest
    static void fromSObject() {
        Test.startTest();
        String query = new QB_Sub('Account').build();
        Test.stopTest();

        Assert.isTrue(query.contains('FROM Account'), 'Query should contains FROM Account');
    }

    @isTest
    static void fromSObjectString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).build();
        Test.stopTest();

        Assert.isTrue(query.contains('FROM Account'), 'Query should contains FROM Account');
    }
}
