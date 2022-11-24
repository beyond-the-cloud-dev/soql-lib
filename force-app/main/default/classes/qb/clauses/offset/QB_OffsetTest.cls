@isTest
public class QB_OffsetTest {
    @isTest
    static void setValidOffset() {
        Integer offset = 1000;

        Test.startTest();
        String query = new QB(Account.sObjectType).setOffset(offset).build();
        Test.stopTest();

        Assert.isTrue(query.contains('OFFSET ' + offset), 'Query should contains OFFSET ' + offset);
    }

    @isTest
    static void setInvalidOffset() {
        Integer invalidOffset = 9999;
        Exception queryException = null;

        Test.startTest();
        try {
            String query = new QB(Account.sObjectType).setOffset(invalidOffset).build();
        } catch (Exception e) {
            queryException = e;
        }
        Test.stopTest();

        Assert.isInstanceOfType(queryException, QueryException.class, 'Query Exception should occur.');
    }
}
