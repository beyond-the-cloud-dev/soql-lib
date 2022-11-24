@isTest
public class QB_ConditionTest {
    @isTest
    static void equalBoolean() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.IsDeleted).equal(false)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((IsDeleted = false))'), 'Query should contains WHERE ((IsDeleted = false))');
    }

    @isTest
    static void notEqualBoolean() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.IsDeleted).notEqual(false)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((IsDeleted != false))'), 'Query should contains WHERE ((IsDeleted != false))');
    }

    @isTest
    static void isNull() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).isNull()).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name = NULL))'), 'Query should contains WHERE ((Name = NULL))');
    }

    @isTest
    static void isNotNull() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).isNotNull()).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name != NULL))'), 'Query should contains WHERE ((Name != NULL))');
    }

    @isTest
    static void equalDecimal() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).equal(100)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount = 100))'), 'Query should contains WHERE ((Amount = 100))');
    }

    @isTest
    static void lessThanDecimal() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).lessThan(100)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount < 100))'), 'Query should contains WHERE ((Amount < 100))');
    }

    @isTest
    static void greaterThanDecimal() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).greaterThan(100)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount > 100))'), 'Query should contains WHERE ((Amount > 100))');
    }

    @isTest
    static void lessThanOrEqualDecimal() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).lessThanOrEqual(100)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount <= 100))'), 'Query should contains WHERE ((Amount <= 100))');
    }

    @isTest
    static void greaterThanOrEqualDecimal() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).greaterThanOrEqual(100)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount >= 100))'), 'Query should contains WHERE ((Amount >= 100))');
    }

    @isTest
    static void notEqualDecimal() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).notEqual(100)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount != 100))'), 'Query should contains WHERE ((Amount != 100))');
    }

    @isTest
    static void lessThanDate() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.CloseDate).lessThan('2050-10-24')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((CloseDate < 2050-10-24))'), 'Query should contains WHERE ((CloseDate < 2050-10-24))');
    }

    @isTest
    static void greaterThanDate() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.CloseDate).greaterThan('2050-10-24')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((CloseDate > 2050-10-24))'), 'Query should contains WHERE ((CloseDate > 2050-10-24))');
    }

    @isTest
    static void lessThanOrEqualDate() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.CloseDate).lessThanOrEqual('2050-10-24')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((CloseDate <= 2050-10-24))'), 'Query should contains WHERE ((CloseDate <= 2050-10-24))');
    }

    @isTest
    static void greaterThanOrEqualDate() {
        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.CloseDate).greaterThanOrEqual('2050-10-24')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((CloseDate >= 2050-10-24))'), 'Query should contains WHERE ((CloseDate >= 2050-10-24))');
    }

    @isTest
    static void equalString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).equal('TestName')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name = \'TestName\'))'), 'Query should contains WHERE ((Name = \'TestName\'))');
    }

    @isTest
    static void notEqualString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).notEqual('TestName')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name != \'TestName\'))'), 'Query should contains WHERE ((Name != \'TestName\'))');
    }

    @isTest
    static void likeAnyBothString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).likeAnyBoth('TestName')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name LIKE \'%TestName%\'))'), 'Query should contains WHERE ((Name LIKE \'%TestName%\'))');
    }

    @isTest
    static void likeAnyLeftString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).likeAnyLeft('TestName')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name LIKE \'%TestName\'))'), 'Query should contains WHERE ((Name LIKE \'%TestName\'))');
    }

    @isTest
    static void likeAnyRightString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).likeAnyRight('TestName')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name LIKE \'TestName%\'))'), 'Query should contains WHERE ((Name LIKE \'TestName%\'))');
    }

    @isTest
    static void containString() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).contain('TestName')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name LIKE \'TestName\'))'), 'Query should contains WHERE ((Name LIKE \'TestName\'))');
    }

    @isTest
    static void inCollectionString() {
        List<String> accountNames = new List<String>{ 'TestName 1', 'TestName 2' };

        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).inCollection(accountNames)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name IN (\'TestName 1\', \'TestName 2\')))'), 'Query should contains WHERE ((Name IN (\'TestName 1\', \'TestName 2\')))');
    }

    @isTest
    static void inCollectionDecimal() {
        List<Decimal> opportunityAmounts = new List<Decimal>{ 10, 20 };

        Test.startTest();
        String query = new QB(Opportunity.sObjectType).withWhere(new QB_Condition(Opportunity.Amount).inCollection(opportunityAmounts)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Amount IN (10, 20)))'), 'Query should contains WHERE ((Amount IN (10, 20)))');
    }

    @isTest
    static void notInString() {
        List<String> accountNames = new List<String>{ 'TestName 1', 'TestName 2' };

        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).notIn(accountNames)).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name NOT IN (\'TestName 1\', \'TestName 2\')))'), 'Query should contains WHERE ((Name NOT IN (\'TestName 1\', \'TestName 2\')))');
    }

    @isTest
    static void bindInCollection() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).bindInCollection('accountNames')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name IN :accountNames))'), 'Query should contains WHERE ((Name IN :accountNames))');
    }

    @isTest
    static void bindNotInCollection() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withWhere(new QB_Condition(Account.Name).bindNotInCollection('accountNames')).build();
        Test.stopTest();

        Assert.isTrue(query.contains('WHERE ((Name NOT IN :accountNames))'), 'Query should contains WHERE ((Name NOT IN :accountNames))');
    }
}
