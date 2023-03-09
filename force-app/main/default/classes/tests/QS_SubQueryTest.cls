@isTest
public class QS_SubQueryTest {

    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Test 1', BillingCity = 'Krakow');

        insert account;

        insert new List<Contact>{
            new Contact(FirstName = 'Joe', LastName = 'Doe', AccountId = account.Id),
            new Contact(FirstName = 'Matt', LastName = 'Hunter', AccountId = account.Id)
        };
    }

    @isTest
    static void subQueryFields() {
        List<Account> reference = [
            SELECT Name, BillingCity,
                (SELECT Id, Name FROM Contacts)
            FROM Account
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
            )
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
            Assert.areEqual(reference[i].Contacts.size(), actual[i].Contacts.size());
        }
    }

    @isTest
    static void relatedFields() {
        List<Account> reference = [
            SELECT Name, BillingCity,
                (
                    SELECT Id, Name,  CreatedBy.Id, CreatedBy.FirstName, CreatedBy.LastName
                    FROM Contacts
                )
            FROM Account
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .relatedFields('CreatedBy', new List<sObjectField>{
                    User.Id, User.FirstName, User.LastName
                })
            )
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
            Assert.areEqual(reference[i].Contacts.size(), actual[i].Contacts.size());
        }
    }

    @isTest
    static void whereAre() {
        List<Account> reference = [
            SELECT Name, BillingCity,
                (
                    SELECT Id, Name, LastName
                    FROM Contacts
                    WHERE LastName = 'Doe'
                )
            FROM Account
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name, Contact.LastName
                })
                .whereAre(QS.Condition.field(Contact.LastName).equal('Doe'))
            )
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
            Assert.areEqual(reference[i].Contacts.size(), actual[i].Contacts.size());

            for (Contact contact : actual[i].Contacts) {
                Assert.areEqual(contact.LastName, 'Doe');
            }
        }
    }

    @isTest
    static void orderBy() {
        List<Account> reference = [
            SELECT Name, BillingCity,
                (
                    SELECT Id, Name, LastName
                    FROM Contacts
                    ORDER BY Name
                )
            FROM Account
        ];

        Test.startTest();
        List<Account> actual = (List<Account>) QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name, Contact.LastName
                })
                .orderBy(Contact.Name)
            )
            .asList();
        Test.stopTest();

        for (Integer i=0 ; i<reference.size() ; i++) {
            Assert.areEqual(reference[i].Name, actual[i].Name);
            Assert.areEqual(reference[i].BillingCity, actual[i].BillingCity);
            Assert.areEqual(reference[i].Contacts.size(), actual[i].Contacts.size());
        }
    }
}
