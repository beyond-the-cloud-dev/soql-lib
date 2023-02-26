@isTest
public class QS_Test {

    @TestSetup
    static void setup() {
        insert new List<Account>{
            new Account(Name = 'Test 1', BillingCity = 'Krakow'),
            new Account(Name = 'Test 2', BillingCity = 'Warsaw')
        };
    }

    @isTest
    static void fields() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
        ];
        List<Account> actual;

        Test.startTest();
        actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<2 ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void relatedFields() {
        List<Account> reference = [
            SELECT CreatedBy.Id, CreatedBy.FirstName, CreatedBy.LastName
            FROM Account
        ];
        List<Account> actual;

        Test.startTest();
        actual = (List<Account>) QS.of(Account.sObjectType)
            .relatedFields('CreatedBy', new List<sObjectField>{
                User.Id, User.FirstName, User.LastName
            })
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<2 ; i++) {
            Assert.areEqual(reference[i].CreatedBy.Id, actual[i].CreatedBy.Id);
            Assert.areEqual(reference[i].CreatedBy.FirstName, actual[i].CreatedBy.FirstName);
            Assert.areEqual(reference[i].CreatedBy.LastName, actual[i].CreatedBy.LastName);
        }
    }
}
