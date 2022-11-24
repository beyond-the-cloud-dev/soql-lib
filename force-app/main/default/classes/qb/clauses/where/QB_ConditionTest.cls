@isTest
public class QB_ConditionTest {
    @isTest
    static void equalBoolean() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.IsDeleted).equal(false)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((IsDeleted = false))'), 'Query should contains WHERE IsDeleted = false');
    }

    @isTest
    static void notEqualBoolean() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.IsDeleted).notEqual(false)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((IsDeleted != false))'), 'Query should contains WHERE IsDeleted != false');
    }
}
