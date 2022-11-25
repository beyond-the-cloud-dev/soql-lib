@isTest
public class QB_Test {
    private final static String ACCOUNT_NAME_1 = 'TestAccount 1';
    private final static String ACCOUNT_NAME_2 = 'TestAccount 2';

    @TestSetup
    static void setup() {
        insert new List<Account>{ new Account(Name = ACCOUNT_NAME_1), new Account(Name = ACCOUNT_NAME_2) };
    }

    @isTest
    static void singleRecord() {
        Test.startTest();
        Account account = (Account) new QB(Account.sObjectType).fields(new List<sObjectField>{ Account.Id, Account.Name }).toSObject();
        Test.stopTest();

        Assert.areEqual(ACCOUNT_NAME_1, account.Name, 'Account Name should be equal ' + ACCOUNT_NAME_1);
    }

    @isTest
    static void multipleRecords() {
        Test.startTest();
        List<Account> accounts = (List<Account>) new QB(Account.sObjectType).fields(new List<sObjectField>{ Account.Id, Account.Name }).toSObjects();
        Test.stopTest();

        Assert.areEqual(2, accounts.size(), 'Should be 2 accounts');
    }

    @isTest
    static void singleRecordWithCondition() {
        Account account = (Account) new QB(Account.sObjectType)
            .fields(new List<sObjectField>{ Account.Id, Account.Name })
            .conditions(new QB_ConditionsGroup().add(new QB_Condition(Account.Name).likeAnyBoth(ACCOUNT_NAME_1)))
            .toSObject();

        Assert.areEqual(ACCOUNT_NAME_1, account.Name, 'Account Name should be equal ' + ACCOUNT_NAME_1);
    }

    @isTest
    static void multipleRecordWithCondition() {
        List<Account> accounts = (List<Account>) new QB(Account.sObjectType)
            .fields(new List<sObjectField>{ Account.Id, Account.Name })
            .conditions(
                new QB_ConditionsGroup()
                    .add(new QB_Condition(Account.Name).likeAnyBoth(ACCOUNT_NAME_1))
                    .add(new QB_Condition(Account.Name).likeAnyBoth(ACCOUNT_NAME_2))
                    .order('(1 OR 2)')
            )
            .toSObjects();

        Assert.areEqual(2, accounts.size(), 'Should be 2 accounts');
    }
}
