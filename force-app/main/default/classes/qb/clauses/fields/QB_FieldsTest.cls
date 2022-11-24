@isTest
public class QB_FieldsTest {
    @isTest
    static void sObjectTypeFields() {
        List<sObjectField> fields = new List<sObjectField>{ Account.Id, Account.Name };

        Test.startTest();
        String query = new QB(Account.sObjectType).fields(fields).build();
        Test.stopTest();

        Assert.isTrue(query.contains('SELECT Id, Name'), 'Query should contains SELECT Id, Name');
    }

    @isTest
    static void commaSeparatedFields() {
        Test.startTest();
        String query = new QB(Account.sObjectType).fields('Id, Name').build();
        Test.stopTest();

        Assert.isTrue(query.contains('SELECT Id, Name'), 'Query should contains SELECT Id, Name');
    }

    @isTest
    static void relationshipFields() {
        Test.startTest();
        String query = new QB(Contact.sObjectType).relationship('Account', new List<sObjectField>{ Account.Id, Account.Name }).build();
        Test.stopTest();

        Assert.isTrue(query.contains('Account.Id, Account.Name'), 'Query should contains Account.Id, Account.Name');
    }
}
