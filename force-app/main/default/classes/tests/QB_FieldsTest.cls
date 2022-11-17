@isTest
public class QB_FieldsTest {
    private final static String ACCOUNT_NAME_1 = 'TestAccount 1';
    private final static String ACCOUNT_NAME_2 = 'TestAccount 2';

    @TestSetup
    static void setup() {
        insert new List<Account>{ new Account(Name = ACCOUNT_NAME_1), new Account(Name = ACCOUNT_NAME_2) };
    }

    @isTest
    static void withSObjectFields() {
        List<sObjectField> fields = new List<sObjectField>{ Account.Id, Account.Name };

        Test.startTest();
        Account retrivedAccount = (Account) new QB(Account.sObjectType).withFields(fields).toObject();
        Test.stopTest();

        Assert.isNotNull(retrivedAccount.get(Account.Id), 'Account Id should be not empty.');
        Assert.isNotNull(retrivedAccount.get(Account.Name), 'Account Name should be not empty.');
    }

    @isTest
    static void withCommaSeparatedFields() {
        Test.startTest();
        Account retrivedAccount = (Account) new QB(Account.sObjectType).withFields('Id, Name').toObject();
        Test.stopTest();

        Assert.isNotNull(retrivedAccount.get('Id'), 'Account Id should be not empty.');
        Assert.isNotNull(retrivedAccount.get('Name'), 'Account Name should be not empty.');
    }

    @isTest
    static void withQbFields() {
        QB_Fields qbFields = new QB_Fields();

        qbFields.addFields(new List<sObjectField>{ Account.Id, Account.Name });

        Test.startTest();
        Account retrivedAccount = (Account) new QB(Account.sObjectType).withFields(qbFields).toObject();
        Test.stopTest();

        Assert.isNotNull(retrivedAccount.get(Account.Id), 'Account Id should be not empty.');
        Assert.isNotNull(retrivedAccount.get(Account.Name), 'Account Name should be not empty.');
    }
}
