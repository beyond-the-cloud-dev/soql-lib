@isTest
public class QB_ConditionsTest {
    @isTest
    static void multipleConditions() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .withWhere(
                new List<QB_Condition>{
                    new QB_Condition(Account.Name).equal('Test'),
                    new QB_Condition(Account.AccountSource).equal('Advertisement'),
                    new QB_Condition(Account.IsDeleted).equal(false)
                }
            )
            .build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('WHERE ((Name = \'Test\' AND AccountSource = \'Advertisement\' AND IsDeleted = false))'),
            'Query should contains WHERE ((Name = \'Test\' AND AccountSource = \'Advertisement\' AND IsDeleted = false))'
        );
    }

    @isTest
    static void multipleConditionsWithOrder() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .withWhere(
                new List<QB_Condition>{
                    new QB_Condition(Account.Name).equal('Test'),
                    new QB_Condition(Account.AccountSource).equal('Advertisement'),
                    new QB_Condition(Account.IsDeleted).equal(false)
                },
                '(1 OR 2) AND 3'
            )
            .build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'),
            'Query should contains WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'
        );
    }

    @isTest
    static void dynamicConditions() {
        QB_Conditions conditions = new QB_Conditions();

        conditions.add(new QB_Condition(Account.Name).equal('Test'));
        conditions.add(new QB_Condition(Account.AccountSource).equal('Advertisement'));
        conditions.add(new QB_Condition(Account.IsDeleted).equal(false));

        conditions.setConditionsOrder('(1 OR 2) AND 3');

        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(conditions).build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'),
            'Query should contains WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'
        );
    }
}
