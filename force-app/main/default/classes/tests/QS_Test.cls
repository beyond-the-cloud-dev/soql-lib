@isTest
public class QS_Test {

    @TestSetup
    static void setup() {
        insert new List<Account>{
            new Account(Name = 'Test 1', BillingCity = 'Krakow'),
            new Account(Name = 'Test 2', BillingCity = 'Warsaw')
        };
    }

    // Fields

    @isTest
    static void count() {
        Integer reference = [
            SELECT Count()
            FROM Account
        ];

        Test.startTest();
        Integer actual = QS.of(Account.sObjectType)
            .count()
            .asInteger();
        Test.stopTest();

        Assert.areEqual(reference, actual);
    }

    @isTest
    static void countField() {
        List<AggregateResult> reference = [
            SELECT Count(Name) names
            FROM Account
        ];

        System.debug(LoggingLevel.DEBUG, ': ' + reference);

        Test.startTest();
        List<AggregateResult> actual = (List<AggregateResult>) QS.of(Account.sObjectType)
            .count(Account.Name, 'names')
            .asList();
        Test.stopTest();

        Assert.areEqual(reference[0].get('names'), actual[0].get('names'));
    }

    @isTest
    static void fields() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
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

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
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

    // Where

    @isTest
    static void simpleWhere() {
        Account reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE Name = 'Test 1'
            LIMIT 1
        ];

        Test.startTest();
        Account actual = (Account) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).equal('Test 1'))
            .setLimit(1)
            .asObject();
        Test.stopTest();

        Assert.areEqual(reference.Name, actual.Name);
        Assert.areEqual(reference.BillingCity, actual.BillingCity);
    }
}
