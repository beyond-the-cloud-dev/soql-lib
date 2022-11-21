@isTest
public class QB_SubQueryTest {
    @isTest
    static void withSubQuery() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withSubQuery(new QB('Contacts').withFields(new List<sObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName })).build();
        Test.stopTest();

        Assert.isTrue(query.contains('SELECT Id, FirstName, LastName FROM Contacts'), 'Query should contains (SELECT Id, FirstName, LastName FROM Contacts)');
    }

    @isTest
    static void withSubQueries() {
        Test.startTest();
        String query = new QB(Account.sObjectType)
            .withSubQueries(
                new List<QB>{
                    new QB('Contacts').withFields(new List<sObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName }),
                    new QB('Opportunities').withFields(new List<sObjectField>{ Opportunity.Id, Opportunity.Amount })
                }
            )
            .build();
        Test.stopTest();

        Assert.isTrue(query.contains('(SELECT Id, FirstName, LastName FROM Contacts), (SELECT Id, Amount FROM Opportunities)'), 'Query should contains (SELECT Id, FirstName, LastName FROM Contacts)');
    }
}
