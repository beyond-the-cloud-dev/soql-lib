@isTest
public class QB_Test {

    private final static String ACCOUNT_NAME = 'TestAccount';

    @TestSetup
    static void setup() {
        Account account = new Account(Name = ACCOUNT_NAME);

        insert new Contact(FirstName = 'Test', LastName = 'Contact');
    }

    @isTest
    static void simpleQuery() {
        Account account = (Account) Database.query(
            new QB_QueryBuilder(Account.sObjectType)
                .withFields(new List<sObjectField>{
                    Account.Id,
                    Account.Name
                })
                .build()
        );

        Assert.areEqual(ACCOUNT_NAME, account.Name, 'Account Name should be equal ' + ACCOUNT_NAME);
    }
}
