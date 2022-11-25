@isTest
public class QB_ConditionsGroupTest {
    @isTest
    static void multipleConditions() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .conditions(
                new QB_ConditionsGroup()
                    .add(new QB_Condition(Account.Name).equal('Test'))
                    .add(new QB_Condition(Account.AccountSource).equal('Advertisement'))
                    .add(new QB_Condition(Account.IsDeleted).equal(false))
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
            .conditions(
                new QB_ConditionsGroup()
                    .add(new QB_Condition(Account.Name).equal('Test'))
                    .add(new QB_Condition(Account.AccountSource).equal('Advertisement'))
                    .add(new QB_Condition(Account.IsDeleted).equal(false))
                    .order('(1 OR 2) AND 3')
            )
            .build();
        Test.stopTest();

        Assert.areEqual('ss', query, 's');

        Assert.isTrue(
            query.contains('WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'),
            'Query should contains WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'
        );
    }

    @isTest
    static void dynamicConditions() {
        QB_ConditionsGroup conditions = new QB_ConditionsGroup();

        conditions.add(new QB_Condition(Account.Name).equal('Test'));
        conditions.add(new QB_Condition(Account.AccountSource).equal('Advertisement'));
        conditions.add(new QB_Condition(Account.IsDeleted).equal(false));

        conditions.order('(1 OR 2) AND 3');

        Test.startTest();
        String query = new QB(Account.sObjectType).conditions(conditions).build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'),
            'Query should contains WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)'
        );
    }
}
