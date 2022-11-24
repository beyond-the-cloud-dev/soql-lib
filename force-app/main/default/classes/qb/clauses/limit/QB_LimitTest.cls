@isTest
public class QB_LimitTest {
    @isTest
    static void setValidLimit() {
        Integer queryLimit = 1000;

        Test.startTest();
        String query = new QB(Account.sObjectType).setLimit(queryLimit).build();
        Test.stopTest();

        Assert.isTrue(query.contains('LIMIT ' + queryLimit), 'Query should contains LIMIT ' + queryLimit);
    }

    @isTest
    static void setInvalidLimit() {
        Integer invalidLimit = 50002;
        Exception queryException = null;

        Test.startTest();
        try {
            String query = new QB(Account.sObjectType).setLimit(invalidLimit).build();
        } catch (Exception e) {
            queryException = e;
        }
        Test.stopTest();

        Assert.isInstanceOfType(queryException, QueryException.class, 'Query Exception should occur.');
    }
}
