@isTest
public class QB_GroupByTest {
    @isTest
    static void withGroupBySObjectField() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withGroupBy(Account.Name).build();
        Test.stopTest();

        Assert.isTrue(query.contains('GROUP BY Name'), 'Query should contains GROUP BY Name');
    }

    @isTest
    static void withGroupBySObjectFields() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withGroupBy(new List<sObjectField>{ Account.AccountSource, Account.Industry }).build();
        Test.stopTest();

        Assert.isTrue(query.contains('GROUP BY AccountSource, Industry'), 'Query should contains GROUP BY AccountSource, Industry');
    }
}
