@isTest
private class QS_ScopeTest {

    @TestSetup
    static void setup() {
        insert new List<Account>{
            new Account(Name = 'Test 1', BillingCity = 'Krakow'),
            new Account(Name = 'Test 2', BillingCity = 'Warsaw')
        };
    }

    @isTest
    static void mineScope() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            USING SCOPE MINE
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .mineScope()
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<2 ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void teamScope() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            USING SCOPE TEAM
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .teamScope()
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<2 ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }
}
