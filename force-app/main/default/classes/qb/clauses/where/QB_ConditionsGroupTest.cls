@isTest
public class QB_ConditionsGroupTest {
    @isTest
    static void multipleConditions() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .condition(new QB_Condition(Account.Name).equal('Test'))
            .condition(new QB_Condition(Account.AccountSource).equal('Advertisement'))
            .condition(new QB_Condition(Account.IsDeleted).equal(false))
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
            .condition(new QB_Condition(Account.Name).equal('Test'))
            .condition(new QB_Condition(Account.AccountSource).equal('Advertisement'))
            .condition(new QB_Condition(Account.IsDeleted).equal(false))
            .conditionsOrder('(1 OR 2) AND 3')
            .build();
        Test.stopTest();

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
        String query = new QB(Account.sObjectType)
        .condition(new QB_Condition(Account.NumberOfEmployees).lessThan(200))
        .condition(conditions).build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('WHERE ((NumberOfEmployees < 200 AND ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)))'),
            'Query should contains WHERE ((NumberOfEmployees < 200 AND ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false)))'
        );
    }

    @isTest
    static void nestedConditions() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .condition(new QB_Condition(Account.Name).equal('Test'))
            .condition(new QB_Condition(Account.AccountSource).equal('Advertisement'))
            .condition(new QB_Condition(Account.IsDeleted).equal(false))
            .condition(new QB_ConditionsGroup().add(new QB_Condition(Account.NumberOfEmployees).equal(200)).add(new QB_Condition(Account.Type).equal('Customer')).order('1 OR 2'))
            .conditionsOrder('(1 OR 2) AND 3 AND 4')
            .build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false AND (NumberOfEmployees = 200 OR Type = \'Customer\'))'),
            'Query should contains WHERE ((Name = \'Test\' OR AccountSource = \'Advertisement\') AND IsDeleted = false AND (NumberOfEmployees = 200 OR Type = \'Customer\'))'
        );
    }
}
