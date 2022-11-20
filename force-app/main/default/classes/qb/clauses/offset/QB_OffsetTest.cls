@isTest
public class QB_OffsetTest {
    @isTest
    static void withValidOffset() {
        Integer offset = 1000;

        Test.startTest();
        String query = new QB(Account.sObjectType).withOffset(offset).build();
        Test.stopTest();

        Assert.isTrue(query.contains('OFFSET ' + offset), 'Query should contains OFFSET ' + offset);
    }

    @isTest
    static void withInvalidOffset() {
        Integer invalidOffset = 9999;
        Exception queryException = null;

        Test.startTest();
        try {
            String query = new QB(Account.sObjectType).withOffset(invalidOffset).build();
        } catch (Exception e) {
            queryException = e;
        }
        Test.stopTest();

        Assert.isInstanceOfType(queryException, QueryException.class, 'Query Exception should occur.');
    }
}
