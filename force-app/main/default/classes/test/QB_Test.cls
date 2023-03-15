@isTest
public class QB_Test {

    // SELECT

    @isTest
    static void count() {
        String soql = QS.of(Account.sObjectType).count().soql();

        Assert.areEqual('SELECT COUNT() FROM Account', soql);
    }

    @isTest
    static void countAs() {
        String soql = QS.of(Account.sObjectType).countAs(Account.Name, 'names').soql();

        Assert.areEqual('SELECT COUNT(Name) names FROM Account', soql);
    }

    @isTest
    static void fields() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            }).soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void relatedFields() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .relatedFields('CreatedBy', new List<sObjectField>{
                User.Id, User.Name
            }).soql();
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name FROM Account', soql);
    }

    // SubQuery

    @isTest
    static void subQueryFields() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryRelatedFields() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .relatedFields('CreatedBy', new List<sObjectField>{
                    User.Id, User.Name
                })
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryWhere() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .whereAre(QS.Condition.field(Contact.LastName).equal('Doe'))
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts WHERE (LastName = :v1)) FROM Account', soql);
    }

    @isTest
    static void subQueryOrderBy() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .orderBy(Contact.Name)
                .sortDesc()
                .nullsLast()
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts ORDER BY Name DESC NULLS LAST) FROM Account', soql);
    }

    @isTest
    static void subQueryOrderByRelated() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .orderByRelated('CreatedBy', User.Name)
                .sortDesc()
                .nullsLast()
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts ORDER BY CreatedBy.Name DESC NULLS LAST) FROM Account', soql);
    }

    @isTest
    static void subQuerySetLimit() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .setLimit(10)
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts LIMIT 10) FROM Account', soql);
    }

    @isTest
    static void subQuerySetOffset() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .setOffset(100)
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts OFFSET 100) FROM Account', soql);
    }

    @isTest
    static void subQueryForReference() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .forReference()
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts FOR REFERENCE) FROM Account', soql);
    }

    @isTest
    static void subQueryForView() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .subQuery(QS.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .forView()
            ).soql();

        Assert.areEqual('SELECT Name, BillingCity , (SELECT Id, Name FROM Contacts FOR VIEW) FROM Account', soql);
    }

    // SCOPE

    @isTest
    static void mineScope() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .mineScope()
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account USING SCOPE MINE', soql);
    }

    @isTest
    static void teamScope() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .teamScope()
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account USING SCOPE TEAM', soql);
    }

    // WHERE

    @isTest
    static void id() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.id().isNotNull())
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Id != :v1)', soql);
    }

    @isTest
    static void equalString() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).equal('Test'))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name = :v1)', soql);
    }

    @isTest
    static void notEqualString() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).notEqual('Test'))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name != :v1)', soql);
    }

    @isTest
    static void lessThan() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThan(10))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees < :v1)', soql);
    }

    @isTest
    static void greaterThan() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThan(10))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees > :v1)', soql);
    }

    @isTest
    static void lessThanOrEqual() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThanOrEqual(10))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees <= :v1)', soql);
    }

    @isTest
    static void greaterThanOrEqual() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees >= :v1)', soql);
    }

    @isTest
    static void likeAnyBoth() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyBoth('Test'))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name LIKE :v1)', soql);
    }

    @isTest
    static void likeAnyLeft() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyLeft('Test'))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name LIKE :v1)', soql);
    }

    @isTest
    static void likeAnyRight() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyRight('Test'))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name LIKE :v1)', soql);
    }

    @isTest
    static void inCollection() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).inCollection(names))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name IN :v1)', soql);
    }


    @isTest
    static void notIn() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).notIn(names))
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name NOT IN :v1)', soql);
    }

    @isTest
    static void isNotNull() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).isNotNull())
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name != :v1)', soql);
    }

    @isTest
    static void isNull() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).isNull())
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name = :v1)', soql);
    }

    @isTest
    static void conditionsGroup() {
        String soql = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.ConditionsGroup
                .add(QS.Condition.field(Account.Name).likeAnyRight('Test'))
                .add(QS.Condition.field(Account.BillingCity).likeAnyRight('Krakow'))
            )
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE ((Name LIKE :v1 AND BillingCity LIKE :v2))', soql);
    }
}
