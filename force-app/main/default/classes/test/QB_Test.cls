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
    static void delegatedScope() {
        String soql = QS.of(Task.sObjectType)
            .delegatedScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Task USING SCOPE DELEGATED', soql);
    }

    @isTest
    static void mineScope() {
        String soql = QS.of(Account.sObjectType)
            .mineScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MINE', soql);
    }

    @isTest
    static void mineAndMyGroupsScope() {
        String soql = QS.of(ProcessInstanceWorkItem.sObjectType)
            .mineAndMyGroupsScope()
            .soql();

        Assert.areEqual('SELECT Id FROM ProcessInstanceWorkitem USING SCOPE MINE_AND_MY_GROUPS', soql);
    }

    @isTest
    static void teamScope() {
        String soql = QS.of(Account.sObjectType)
            .teamScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE TEAM', soql);
    }

    // WHERE

    @isTest
    static void id() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.id().isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Id != :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void equalString() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).equal('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void notEqualString() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).notEqual('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name != :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void lessThan() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThan(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees < :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void greaterThan() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThan(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees > :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void lessThanOrEqual() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).lessThanOrEqual(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees <= :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void greaterThanOrEqual() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (NumberOfEmployees >= :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void likeAnyBoth() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyBoth('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test%', binding.get('v1'));
    }

    @isTest
    static void likeAnyLeft() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyLeft('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test', binding.get('v1'));
    }

    @isTest
    static void likeAnyRight() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).likeAnyRight('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name LIKE :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test%', binding.get('v1'));
    }

    @isTest
    static void inCollection() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).inCollection(names));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name IN :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }


    @isTest
    static void notIn() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).notIn(names));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name NOT IN :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @isTest
    static void isNotNull() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name != :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void isNull() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.Condition.field(Account.Name).isNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE (Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void conditionsGroup() {
        QS builder = QS.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(QS.ConditionsGroup
                .add(QS.Condition.field(Account.Name).equal('Test'))
                .add(QS.Condition.field(Account.BillingCity).equal('Krakow'))
            );

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE ((Name = :v1 AND BillingCity = :v2))', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    // GROUP BY

    @isTest
    static void groupBy() {
        String soql = QS.of(Lead.sObjectType)
            .fields(new List<sObjectField>{
                Lead.LeadSource
            })
            .groupBy(Lead.LeadSource)
            .soql();

        Assert.areEqual('SELECT LeadSource FROM Lead GROUP BY LeadSource', soql);
    }

    // ORDER BY

    @isTest
    static void orderBy() {
        String soql = QS.of(Account.sObjectType)
            .orderBy(Account.Industry).sortDesc().nullsLast()
            .orderBy(Account.Id)
            .soql();

        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry DESC NULLS LAST, Id ASC NULLS FIRST', soql);
    }

    @isTest
    static void orderByRelated() {
        String soql = QS.of(Contact.sObjectType)
            .orderByRelated('Account', Account.Name)
            .soql();

        Assert.areEqual('SELECT Id FROM Contact ORDER BY Account.Name ASC NULLS FIRST', soql);
    }

    // LIMIT

    @isTest
    static void setLimit() {
        String soql = QS.of(Account.sObjectType)
            .setLimit(100)
            .soql();

        Assert.areEqual('SELECT Id FROM Account LIMIT 100', soql);
    }

    // OFFSET

    @isTest
    static void setOffset() {
        String soql = QS.of(Account.sObjectType)
            .setOffset(100)
            .soql();

        Assert.areEqual('SELECT Id FROM Account OFFSET 100', soql);
    }

    // FOR

    @isTest
    static void forReference() {
        String soql = QS.of(Account.sObjectType)
            .forReference()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR REFERENCE', soql);
    }

    @isTest
    static void forView() {
        String soql = QS.of(Account.sObjectType)
            .forView()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR VIEW', soql);
    }

    @isTest
    static void forUpdate() {
        String soql = QS.of(Account.sObjectType)
            .forUpdate()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR UPDATE', soql);
    }

    @isTest
    static void allRows() {
        String soql = QS.of(Account.sObjectType)
            .allRows()
            .soql();

        Assert.areEqual('SELECT Id FROM Account ALL ROWS', soql);
    }
}
