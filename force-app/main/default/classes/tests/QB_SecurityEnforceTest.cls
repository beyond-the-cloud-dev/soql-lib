@isTest
public class QB_SecurityEnforceTest {

    @isTest
    static void withSecurityEnforced() {
        Test.startTest();
        String query = new QB(Account.sObjectType).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WITH SECURITY_ENFORCED'), 'Query should contains WITH SECURITY_ENFORCED');
    }

    @isTest
    static void withoutSecurityEnforced() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withoutSecurityEnforced().build();
        Test.stopTest();

        Assert.isFalse(query.contains('WITH SECURITY_ENFORCED'), 'Query should NOT contain WITH SECURITY_ENFORCED');
    }
}
