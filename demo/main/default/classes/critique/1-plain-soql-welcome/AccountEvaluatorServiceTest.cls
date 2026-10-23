@IsTest
private class AccountEvaluatorServiceTest {
    @IsTest
    static void getAccountIds() {
        SOQLEvaluator.mock('AccountEvaluatorService.getAccountIds').thenReturn(new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        });

        Test.startTest();
        Set<Id> result = AccountEvaluatorService.getAccountIds('Technology');
        Test.stopTest();

        Assert.areEqual(2, result.size());
    }
}
