@isTest
public class QB_ConditionsTest {

    @TestSetup
    static void setup() {
        insert new List<Account>{
            new Account(Name = 'Test 1', BillingCity = 'Krakow', Website = 'www.test1.com', NumberOfEmployees = 10),
            new Account(Name = 'Test 2', BillingCity = 'Warsaw', NumberOfEmployees = 5)
        };
    }

    @isTest
    static void id() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE Id != null
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.id().isNotNull())
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void equalString() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE Name = 'Test 1'
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).equal('Test 1'))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void notEqualString() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE Name != 'Test 1'
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).notEqual('Test 1'))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void lessThan() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NumberOfEmployees < 10
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThan(10))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }


    @isTest
    static void greaterThan() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NumberOfEmployees > 6
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThan(6))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void lessThanOrEqual() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NumberOfEmployees <= 5
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThanOrEqual(5))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void greaterThanOrEqual() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NumberOfEmployees >= 10
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void likeAnyBoth() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NAME LIKE '%st%'
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyBoth('st'))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void likeAnyLeft() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NAME LIKE '%st 1'
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyLeft('st 1'))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void likeAnyRight() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NAME LIKE 'Test%'
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyRight('Test'))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void inCollection() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NAME IN :names
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).inCollection(names))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void notIn() {
        List<String> names = new List<String>{ 'Test 1' };

        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE NAME NOT IN :names
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).notIn(names))
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void isNotNull() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE Name != null
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).isNotNull())
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }

    @isTest
    static void isNull() {
        List<Account> reference = [
            SELECT Name, BillingCity
            FROM Account
            WHERE Name = null
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Website).isNull())
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
        }
    }
}
