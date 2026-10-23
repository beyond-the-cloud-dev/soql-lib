@IsTest
private class AccountControllerTest {
    @IsTest
    static void getPartnerAccounts() {
        SOQL.mock('AccountController.getPartnerAccounts').thenReturn(new List<Account>{
            new Account(Name = 'Partner 1'),
            new Account(Name = 'Partner 2')
        });

        Test.startTest();
        List<Account> result = AccountController.getPartnerAccounts('Partner');
        Test.stopTest();

        Assert.areEqual(2, result.size());
    }

    @IsTest
    static void getPartnerAccount() {
        SOQL.mock('AccountController.getPartnerAccount').thenReturn(new Account(Name = 'Acme'));

        Test.startTest();
        Account result = AccountController.getPartnerAccount('Acme');
        Test.stopTest();

        Assert.areEqual('Acme', result.Name);
    }

    @IsTest
    static void getPartnerAccountsFromStaticResource() {
        SOQL.mock('AccountController.getPartnerAccounts').thenReturn(Test.loadData(Account.SObjectType, 'ProjectAccounts'));

        Test.startTest();
        List<Account> result = AccountController.getPartnerAccounts('Acme');
        Test.stopTest();

        Assert.areEqual(5, result.size());
    }

    @IsTest
    static void countPartnerAccounts() {
        SOQL.mock('AccountController.countPartnerAccounts').thenReturn(2);

        Test.startTest();
        Integer result = AccountController.countPartnerAccounts();
        Test.stopTest();

        Assert.areEqual(2, result);
    }
}
