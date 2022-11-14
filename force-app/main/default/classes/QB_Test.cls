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
       Account account = (Account) new QB(Account.sObjectType).withFields(new List<sObjectField>{ Account.Id, Account.Name }).toObject();

       System.assertEquals(ACCOUNT_NAME_1, account.Name, 'Account Name should be equal ' + ACCOUNT_NAME_1);
    }

    @isTest
    static void multipleRecords() {
        List<Account> accounts = (List<Account>) new QB(Account.sObjectType).withFields(new List<sObjectField>{ Account.Id, Account.Name }).toList();

        System.assertEquals(2, accounts.size(), 'Should be 2 accounts');
    }

    @isTest
    static void singleRecordWithCondition() {
        Account account = (Account) new QB(Account.sObjectType)
            .withFields(new List<sObjectField>{ Account.Id, Account.Name })
            .withFields(new List<sObjectField>{ Account.Id, Account.FirstName })
            .withWhere(new QB_StringCondition(Account.Name).likeAnyBoth(ACCOUNT_NAME_1))
            .toObject();

        System.assertEquals(ACCOUNT_NAME_1, account.Name, 'Account Name should be equal ' + ACCOUNT_NAME_1);
    }
}
