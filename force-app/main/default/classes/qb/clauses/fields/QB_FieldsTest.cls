@isTest
public class QB_FieldsTest {
    @isTest
    static void withSObjectFields() {
        List<sObjectField> fields = new List<sObjectField>{ Account.Id, Account.Name };

        Test.startTest();
        String query = new QB(Account.sObjectType).withFields(fields).build();
        Test.stopTest();

        Assert.isTrue(query.contains('SELECT Id, Name'), 'Query should contains SELECT Id, Name');
    }

    @isTest
    static void withCommaSeparatedFields() {
        Test.startTest();
        String query = new QB(Account.sObjectType).withFields('Id, Name').build();
        Test.stopTest();

        Assert.isTrue(query.contains('SELECT Id, Name'), 'Query should contains SELECT Id, Name');
    }

    @isTest
    static void withRelationshipFields() {
        Test.startTest();
        String query = new QB(Contact.sObjectType).withRelationshipFields('Account', new List<sObjectField>{ Account.Id, Account.Name }).build();
        Test.stopTest();

        Assert.isTrue(query.contains('Account.Id, Account.Name'), 'Query should contains Account.Id, Account.Name');
    }
}
