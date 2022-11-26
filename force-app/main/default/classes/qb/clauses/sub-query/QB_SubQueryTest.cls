@isTest
public class QB_SubQueryTest {
    @isTest
    static void subQuery() {
        Test.startTest();
        String query = new QB(Account.sObjectType).subQuery(new QB_SubQuery('Contacts').fields(new List<sObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName })).build();
        Test.stopTest();

        Assert.isTrue(query.contains('SELECT Id, FirstName, LastName FROM Contacts'), 'Query should contains (SELECT Id, FirstName, LastName FROM Contacts)');
    }

    @isTest
    static void subQueries() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .subQuery(new QB_SubQuery('Contacts').fields(new List<sObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName }))
            .subQuery(new QB_SubQuery('Opportunities').fields(new List<sObjectField>{ Opportunity.Id, Opportunity.Amount }))
            .build();
        Test.stopTest();

        Assert.isTrue(
            query.contains('(SELECT Id, FirstName, LastName FROM Contacts), (SELECT Id, Amount FROM Opportunities)'),
            'Query should contains (SELECT Id, FirstName, LastName FROM Contacts)'
        );
    }
}
