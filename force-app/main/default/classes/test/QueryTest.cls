@isTest
public class QueryTest {

    // SELECT

    @isTest
    static void count() {
        String soql = Query.of(Account.sObjectType).count().soql();

        Assert.areEqual('SELECT COUNT() FROM Account', soql);
    }

    @isTest
    static void countAs() {
        String soql = Query.of(Account.sObjectType).countAs(Account.Name, 'names').soql();

        Assert.areEqual('SELECT COUNT(Name) names FROM Account', soql);
    }

    @isTest
    static void field() {
        String soql = Query.of(Account.sObjectType)
            .field(Account.Name)
            .field(Account.BillingCity)
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void fields() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            }).soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void commaSeparatedFields() {
        String soql = Query.of(Account.sObjectType)
            .fields('Id, Name, BillingCity').soql();

        Assert.areEqual('SELECT Id, Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void relatedFields() {
        String soql = Query.of(Account.sObjectType)
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
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryRelatedFields() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .relatedFields('CreatedBy', new List<sObjectField>{
                    User.Id, User.Name
                })
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryWhere() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .whereAre(Query.Condition.field(Contact.LastName).equal('Doe'))
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts WHERE LastName = :v1) FROM Account', soql);
    }

    @isTest
    static void subQueryOrderBy() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .orderBy(Contact.Name)
                .sortDesc()
                .nullsLast()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY Name DESC NULLS LAST) FROM Account', soql);
    }

    @isTest
    static void subQueryOrderByRelated() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .orderByRelated('CreatedBy', User.Name)
                .sortDesc()
                .nullsLast()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY CreatedBy.Name DESC NULLS LAST) FROM Account', soql);
    }

    @isTest
    static void subQuerySetLimit() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .setLimit(10)
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts LIMIT 10) FROM Account', soql);
    }

    @isTest
    static void subQueryOffset() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .offset(100)
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts OFFSET 100) FROM Account', soql);
    }

    @isTest
    static void subQueryForReference() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .forReference()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR REFERENCE) FROM Account', soql);
    }

    @isTest
    static void subQueryForView() {
        String soql = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name
            })
            .subQuery(Query.Sub.of('Contacts')
                .fields(new List<sObjectField>{
                    Contact.Id, Contact.Name
                })
                .forView()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR VIEW) FROM Account', soql);
    }

    // SCOPE

    @isTest
    static void delegatedScope() {
        String soql = Query.of(Task.sObjectType)
            .delegatedScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Task USING SCOPE DELEGATED', soql);
    }

    @isTest
    static void mineScope() {
        String soql = Query.of(Account.sObjectType)
            .mineScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MINE', soql);
    }

    @isTest
    static void mineAndMyGroupsScope() {
        String soql = Query.of(ProcessInstanceWorkItem.sObjectType)
            .mineAndMyGroupsScope()
            .soql();

        Assert.areEqual('SELECT Id FROM ProcessInstanceWorkitem USING SCOPE MINE_AND_MY_GROUPS', soql);
    }

    @isTest
    static void myTerritoryScope() {
        String soql = Query.of(Account.sObjectType)
            .myTerritoryScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TERRITORY', soql);
    }

    @isTest
    static void myTeamTerritoryScope() {
        String soql = Query.of(Account.sObjectType)
            .myTeamTerritoryScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TEAM_TERRITORY', soql);
    }

    @isTest
    static void teamScope() {
        String soql = Query.of(Account.sObjectType)
            .teamScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE TEAM', soql);
    }

    // WHERE

    @isTest
    static void id() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.id().isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void recordTypeDeveloperName() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.recordTypeDeveloperName().isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE RecordType.DeveloperName != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void relatedField() {
        Query builder = Query.of(Contact.sObjectType)
            .whereAre(Query.Condition.relatedField('Account', Account.Name).equal('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Contact WHERE Account.Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void equalString() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).equal('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void notEqualString() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).notEqual('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void lessThan() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.NumberOfEmployees).lessThan(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees < :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void greaterThan() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.NumberOfEmployees).greaterThan(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees > :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void lessThanOrEqual() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.NumberOfEmployees).lessThanOrEqual(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees <= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void greaterThanOrEqual() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.NumberOfEmployees).greaterThanOrEqual(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void likeAnyBoth() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).likeAnyBoth('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test%', binding.get('v1'));
    }

    @isTest
    static void likeAnyLeft() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).likeAnyLeft('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test', binding.get('v1'));
    }

    @isTest
    static void likeAnyRight() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).likeAnyRight('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test%', binding.get('v1'));
    }

    @isTest
    static void isIn() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).isIn(names));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }


    @isTest
    static void isNotIn() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        Query builder = Query.of(Account.sObjectType)
            .fields(new List<sObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(Query.Condition.field(Account.Name).isNotIn(names));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE Name NOT IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @isTest
    static void isNotNull() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void isNull() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Name).isNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void conditionsGroup() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.ConditionsGroup
                .add(Query.Condition.field(Account.Name).equal('Test'))
                .add(Query.Condition.field(Account.BillingCity).equal('Krakow'))
            );

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @isTest
    static void nestedConditionsGroup() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.ConditionsGroup
                .add(Query.Condition.field(Account.Name).equal('Test'))
                .add(Query.Condition.field(Account.BillingCity).equal('Krakow'))
                .add(Query.ConditionsGroup
                    .add(Query.Condition.field(Account.Name).equal('Test 2'))
                    .add(Query.Condition.field(Account.BillingCity).equal('Warsaw'))
                    .order('1 OR 2')
                )
            );

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2 AND (Name = :v3 OR BillingCity = :v4))', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
        Assert.areEqual('Test 2', binding.get('v3'));
        Assert.areEqual('Warsaw', binding.get('v4'));
    }

    @isTest
    static void inInnerJoin() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Id).isIn(
                Query.InnerJoin.of(Contact.sObjectType)
                    .field(Contact.AccountId)
                    .whereAre(Query.Condition.field(Contact.Name).equal('My Contact'))
            ));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }


    @isTest
    static void isNotInInnerJoin() {
        Query builder = Query.of(Account.sObjectType)
            .whereAre(Query.Condition.field(Account.Id).isNotIn(
                Query.InnerJoin.of(Contact.sObjectType)
                    .field(Contact.AccountId)
                    .whereAre(Query.Condition.field(Contact.Name).equal('My Contact'))
            ));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }

    // GROUP BY

    @isTest
    static void groupBy() {
        String soql = Query.of(Lead.sObjectType)
            .fields(new List<sObjectField>{
                Lead.LeadSource
            })
            .groupBy(Lead.LeadSource)
            .soql();

        Assert.areEqual('SELECT LeadSource FROM Lead GROUP BY LeadSource', soql);
    }

    @isTest
    static void groupByRollup() {
        String soql = Query.of(Lead.sObjectType)
            .fields(new List<sObjectField>{
                Lead.LeadSource
            })
            .countAs(Lead.Name, 'cnt')
            .groupByRollup(Lead.LeadSource)
            .soql();

        Assert.areEqual('SELECT LeadSource, COUNT(Name) cnt FROM Lead GROUP BY ROLLUP(LeadSource)', soql);
    }

    // ORDER BY

    @isTest
    static void orderBy() {
        String soql = Query.of(Account.sObjectType)
            .orderBy(Account.Industry).sortDesc().nullsLast()
            .orderBy(Account.Id)
            .soql();

        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry DESC NULLS LAST, Id ASC NULLS FIRST', soql);
    }

    @isTest
    static void orderByRelated() {
        String soql = Query.of(Contact.sObjectType)
            .orderByRelated('Account', Account.Name)
            .soql();

        Assert.areEqual('SELECT Id FROM Contact ORDER BY Account.Name ASC NULLS FIRST', soql);
    }

    // LIMIT

    @isTest
    static void setLimit() {
        String soql = Query.of(Account.sObjectType)
            .setLimit(100)
            .soql();

        Assert.areEqual('SELECT Id FROM Account LIMIT 100', soql);
    }

    // OFFSET

    @isTest
    static void offset() {
        String soql = Query.of(Account.sObjectType)
            .offset(100)
            .soql();

        Assert.areEqual('SELECT Id FROM Account OFFSET 100', soql);
    }

    // FOR

    @isTest
    static void forReference() {
        String soql = Query.of(Account.sObjectType)
            .forReference()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR REFERENCE', soql);
    }

    @isTest
    static void forView() {
        String soql = Query.of(Account.sObjectType)
            .forView()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR VIEW', soql);
    }

    @isTest
    static void forUpdate() {
        String soql = Query.of(Account.sObjectType)
            .forUpdate()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR UPDATE', soql);
    }

    @isTest
    static void allRows() {
        String soql = Query.of(Account.sObjectType)
            .allRows()
            .soql();

        Assert.areEqual('SELECT Id FROM Account ALL ROWS', soql);
    }

    // Predefinied

    @isTest
    static void getById() {
        Id accountId = '0013V00000WNCwCQAX';

        Query builder = Query.of(Account.sObjectType).getById(accountId);

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(accountId, binding.get('v1'));
    }

    @isTest
    static void getByIds() {
        List<Id> accountIds = new List<Id>{ '0013V00000WNCwCQAX' };

        Query builder = Query.of(Account.sObjectType).getByIds(accountIds);

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(accountIds, binding.get('v1'));
    }

    // Functional

    @isTest
    static void withoutSharing() {
        insertCases();

        System.runAs(standardUser()) {
            List<Case> cases = Query.of(Case.sObjectType).systemMode().withoutSharing().asList();
            Assert.areEqual(2, cases.size());
        }
    }

    @isTest
    static void withoutSharingCount() {
        insertCases();

        System.runAs(standardUser()) {
            Integer casesAmount = Query.of(Case.sObjectType).count().systemMode().withoutSharing().asInteger();
            Assert.areEqual(2, casesAmount);
        }
    }

    @isTest
    static void withSharing() {
        insertTasks();

        System.runAs(standardUser()) {
            List<Task> tasks = Query.of(Task.sObjectType).systemMode().withSharing().asList();
            Assert.areEqual(0, tasks.size());
        }
    }

    @isTest
    static void withSharingCount() {
        insertTasks();

        System.runAs(standardUser()) {
            Integer tasksAmount = Query.of(Task.sObjectType).count().systemMode().withSharing().asInteger();
            Assert.areEqual(0, tasksAmount);
        }
    }

    static void insertCases() {
        insert new List<Case>{
            new Case(Status = 'New', Origin = 'Web'),
            new Case(Status = 'New', Origin = 'Web')
        };
    }

    static void insertTasks() {
        insert new List<Task>{
            new Task(Subject = 'Test'),
            new Task(Subject = 'Test')
        };
    }

    static User standardUser() {
        return new User(
            Alias = 'newUser',
            Email = 'newuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'queryselector@testorg.com'
        );
    }

    @isTest
    static void mocking() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };

        Query.setMock('mockingQuery', accounts);

        List<Account> result = Query.of(Account.sObjectType).mocking('mockingQuery').asList();

        Assert.areEqual(accounts, result);
    }

    @isTest
    static void mockingCount() {
        Query.setCountMock('mockingQuery', 2);

        Integer result = Query.of(Account.sObjectType).mocking('mockingQuery').asInteger();

        Assert.areEqual(2, result);
    }


    @isTest
    static void asObject() {
        Account acc = new Account(Name = 'Test 1');

        insert acc;

        Account result = (Account) Query.of(Account.sObjectType).asObject();

        Assert.areEqual(acc.Id, result.Id);
    }

    @isTest
    static void asObjectCatchOutOfBounds() {
        Account result = (Account) Query.of(Account.sObjectType).asObject();

        Assert.areEqual(null, result);
    }

    @isTest
    static void asList() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };

        insert accounts;

        List<Account> result = Query.of(Account.sObjectType).asList();

        Assert.areEqual(accounts.size(), result.size());
    }

    @isTest
    static void asAggregated() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };

        insert accounts;

        List<AggregateResult> result = Query.of(Account.sObjectType).countAs(Account.Name, 'names').asAggregated();

        Assert.areEqual(accounts.size(), result[0].get('names'));
    }

    @isTest
    static void asInteger() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };

        insert accounts;

        Integer result = Query.of(Account.sObjectType).count().asInteger();

        Assert.areEqual(accounts.size(), result);
    }

    @isTest
    static void preview() {
        Query.of(Account.sObjectType).preview().asList();
    }

    @isTest
    static void previewCount() {
        Query.of(Account.sObjectType).count().preview().asInteger();
    }
}
