@isTest
private class SOQLTest {

    // SELECT

    @isTest
    static void count() {
        String soql = SOQL.of(Account.SObjectType).count().soql();

        Assert.areEqual('SELECT COUNT() FROM Account', soql);
    }

    @isTest
    static void countAs() {
        String soql = SOQL.of(Account.SObjectType).countAs(Account.Name, 'names').soql();

        Assert.areEqual('SELECT COUNT(Name) names FROM Account', soql);
    }

    @isTest
    static void withField() {
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(Account.BillingCity)
            .soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void withFields() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name, Account.BillingCity
            }).soql();

        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void withCommaSeparatedFields() {
        String soql = SOQL.of(Account.SObjectType)
            .with('Id, Name, BillingCity')
            .soql();

        Assert.areEqual('SELECT Id, Name, BillingCity FROM Account', soql);
    }

    @isTest
    static void withRelatedFields() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name, Account.BillingCity
            })
            .with('CreatedBy', new List<SObjectField>{
                User.Id, User.Name
            }).soql();
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name FROM Account', soql);
    }

    // SubQuery

    @isTest
    static void subQueryField() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id)
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryFields() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryRelatedFields() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .with('CreatedBy', new List<SObjectField>{
                    User.Id, User.Name
                })
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM Contacts) FROM Account', soql);
    }

    @isTest
    static void subQueryWhere() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .whereAre(SOQL.Filter.with(Contact.LastName).equal('Doe'))
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts WHERE LastName = :v1) FROM Account', soql);
    }

    @isTest
    static void subQueryOrderBy() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
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
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .orderBy('CreatedBy', User.Name)
                .sortDesc()
                .nullsLast()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY CreatedBy.Name DESC NULLS LAST) FROM Account', soql);
    }

    @isTest
    static void subQuerySetLimit() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .setLimit(10)
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts LIMIT 10) FROM Account', soql);
    }

    @isTest
    static void subQueryOffset() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .offset(100)
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts OFFSET 100) FROM Account', soql);
    }

    @isTest
    static void subQueryForReference() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .forReference()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR REFERENCE) FROM Account', soql);
    }

    @isTest
    static void subQueryForView() {
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .forView()
            ).soql();

        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR VIEW) FROM Account', soql);
    }

    // SCOPE

    @isTest
    static void delegatedScope() {
        String soql = SOQL.of(Task.SObjectType)
            .delegatedScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Task USING SCOPE DELEGATED', soql);
    }

    @isTest
    static void mineScope() {
        String soql = SOQL.of(Account.SObjectType)
            .mineScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MINE', soql);
    }

    @isTest
    static void mineAndMyGroupsScope() {
        String soql = SOQL.of(ProcessInstanceWorkItem.SObjectType)
            .mineAndMyGroupsScope()
            .soql();

        Assert.areEqual('SELECT Id FROM ProcessInstanceWorkitem USING SCOPE MINE_AND_MY_GROUPS', soql);
    }

    @isTest
    static void myTerritoryScope() {
        String soql = SOQL.of(Account.SObjectType)
            .myTerritoryScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TERRITORY', soql);
    }

    @isTest
    static void myTeamTerritoryScope() {
        String soql = SOQL.of(Account.SObjectType)
            .myTeamTerritoryScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TEAM_TERRITORY', soql);
    }

    @isTest
    static void teamScope() {
        String soql = SOQL.of(Account.SObjectType)
            .teamScope()
            .soql();

        Assert.areEqual('SELECT Id FROM Account USING SCOPE TEAM', soql);
    }

    // WHERE

    @isTest
    static void id() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.id().isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void recordType() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.recordType().isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE RecordType.DeveloperName != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void withRelatedFieldFilter() {
        SOQL builder = SOQL.of(Contact.SObjectType)
            .whereAre(SOQL.Filter.with('Account', Account.Name).equal('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Contact WHERE Account.Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void equalString() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).equal('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void notEqualString() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notEqual('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @isTest
    static void lessThan() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThan(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees < :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void greaterThan() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThan(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees > :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void lessThanOrEqual() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThanOrEqual(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees <= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void greaterThanOrEqual() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @isTest
    static void likeAny() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).likeAny('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test%', binding.get('v1'));
    }

    @isTest
    static void likeAnyLeft() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).likeAnyLeft('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test', binding.get('v1'));
    }

    @isTest
    static void likeAnyRight() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).likeAnyRight('Test'));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test%', binding.get('v1'));
    }

    @isTest
    static void isIn() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isIn(names));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }


    @isTest
    static void isNotIn() {
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        SOQL builder = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(SOQL.Filter.with(Account.Name).isNotIn(names));

        String soql = builder.soql();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE Name NOT IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @isTest
    static void isNotNull() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isNotNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void isNull() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isNull());

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @isTest
    static void conditionsGroup() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).equal('Test'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
            );

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @isTest
    static void nestedConditionsGroup() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).equal('Test'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
                .add(SOQL.FiltersGroup
                    .add(SOQL.Filter.with(Account.Name).equal('Test 2'))
                    .add(SOQL.Filter.with(Account.BillingCity).equal('Warsaw'))
                    .conditionLogic('1 OR 2')
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
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).isIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
            ));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }


    @isTest
    static void isNotInInnerJoin() {
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).isNotIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
            ));

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }

    // GROUP BY

    @isTest
    static void groupBy() {
        String soql = SOQL.of(Lead.SObjectType)
            .with(new List<SObjectField>{
                Lead.LeadSource
            })
            .groupBy(Lead.LeadSource)
            .soql();

        Assert.areEqual('SELECT LeadSource FROM Lead GROUP BY LeadSource', soql);
    }

    @isTest
    static void groupByRollup() {
        String soql = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource)
            .countAs(Lead.Name, 'cnt')
            .groupByRollup(Lead.LeadSource)
            .soql();

        Assert.areEqual('SELECT LeadSource, COUNT(Name) cnt FROM Lead GROUP BY ROLLUP(LeadSource)', soql);
    }

    // ORDER BY

    @isTest
    static void orderBy() {
        String soql = SOQL.of(Account.SObjectType)
            .orderBy(Account.Industry).sortDesc().nullsLast()
            .orderBy(Account.Id)
            .soql();

        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry DESC NULLS LAST, Id ASC NULLS FIRST', soql);
    }

    @isTest
    static void orderByRelated() {
        String soql = SOQL.of(Contact.SObjectType)
            .orderBy('Account', Account.Name)
            .soql();

        Assert.areEqual('SELECT Id FROM Contact ORDER BY Account.Name ASC NULLS FIRST', soql);
    }

    // LIMIT

    @isTest
    static void setLimit() {
        String soql = SOQL.of(Account.SObjectType)
            .setLimit(100)
            .soql();

        Assert.areEqual('SELECT Id FROM Account LIMIT 100', soql);
    }

    // OFFSET

    @isTest
    static void offset() {
        String soql = SOQL.of(Account.SObjectType)
            .offset(100)
            .soql();

        Assert.areEqual('SELECT Id FROM Account OFFSET 100', soql);
    }

    // FOR

    @isTest
    static void forReference() {
        String soql = SOQL.of(Account.SObjectType)
            .forReference()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR REFERENCE', soql);
    }

    @isTest
    static void forView() {
        String soql = SOQL.of(Account.SObjectType)
            .forView()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR VIEW', soql);
    }

    @isTest
    static void forUpdate() {
        String soql = SOQL.of(Account.SObjectType)
            .forUpdate()
            .soql();

        Assert.areEqual('SELECT Id FROM Account FOR UPDATE', soql);
    }

    @isTest
    static void allRows() {
        String soql = SOQL.of(Account.SObjectType)
            .allRows()
            .soql();

        Assert.areEqual('SELECT Id FROM Account ALL ROWS', soql);
    }

    // Predefinied

    @isTest
    static void getById() {
        Id accountId = '0013V00000WNCwCQAX';

        SOQL builder = SOQL.of(Account.SObjectType).byId(accountId);

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(accountId, binding.get('v1'));
    }

    @isTest
    static void byIdsSet() {
        Set<Id> accountIds = new Set<Id>{ '0013V00000WNCwCQAX' };

        SOQL builder = SOQL.of(Account.SObjectType).byIds(accountIds);

        String soql = builder.soql();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(new List<Id>(accountIds), binding.get('v1'));
    }

    @isTest
    static void byIdsList() {
        List<Id> accountIds = new List<Id>{ '0013V00000WNCwCQAX' };

        SOQL builder = SOQL.of(Account.SObjectType).byIds(accountIds);

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
            List<Case> cases = SOQL.of(Case.SObjectType).systemMode().withoutSharing().asList();
            Assert.areEqual(2, cases.size());
        }
    }

    @isTest
    static void withoutSharingCount() {
        insertCases();

        System.runAs(standardUser()) {
            Integer casesAmount = SOQL.of(Case.SObjectType).count().systemMode().withoutSharing().asInteger();
            Assert.areEqual(2, casesAmount);
        }
    }

    @isTest
    static void withSharing() {
        insertTasks();

        System.runAs(standardUser()) {
            List<Task> tasks = SOQL.of(Task.SObjectType).systemMode().withSharing().asList();
            Assert.areEqual(0, tasks.size());
        }
    }

    @isTest
    static void withSharingCount() {
        insertTasks();

        System.runAs(standardUser()) {
            Integer tasksAmount = SOQL.of(Task.SObjectType).count().systemMode().withSharing().asInteger();
            Assert.areEqual(0, tasksAmount);
        }
    }

    @isTest
    static void stripInaccessible() {
        insertTasks();

        System.runAs(standardUser()) {
            List<Task> tasks = SOQL.of(Task.SObjectType)
                .with(Task.Type)
                .systemMode()
                .stripInaccessible()
                .withoutSharing()
                .asList();

            Exception queryException = null;

            try {
                String inaccessibleFieldValue = tasks[0].Type;
            } catch(Exception e) {
                queryException = e;
            }

            Assert.areEqual(
                'SObject row was retrieved via SOQL without querying the requested field: Task.Type',
                queryException.getMessage()
            );
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
            new Task(Subject = 'Test', Type = 'Other'),
            new Task(Subject = 'Test', Type = 'Other')
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
    static void mockId() {
        List<Account> accounts = getAccount();

        SOQL.setMock('mockingQuery', accounts);

        List<Account> result = SOQL.of(Account.SObjectType).mockId('mockingQuery').asList();

        Assert.areEqual(accounts, result);
    }

    @isTest
    static void mockingSingleRecord() {
        Account testAccount = new Account(Name = 'Test 1');

        SOQL.setMock('mockingQuery', testAccount);

        Account result = (Account) SOQL.of(Account.sObjectType).mockId('mockingQuery').asObject();

        Assert.areEqual(testAccount, result);
    }

    @isTest
    static void mockingStaticResource() {
        SOQL.setMock('mockingQuery', 'testAccounts');

        try {
            List<Account> result = SOQL.of(Account.sObjectType).mockId('mockingQuery').asList();
        } catch (Exception missingStaticResource){
            Assert.isInstanceOfType(missingStaticResource, NullPointerException.class);
        }
    }

    @isTest
    static void mockingCount() {
        SOQL.setCountMock('mockingQuery', 2);

        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').asInteger();

        Assert.areEqual(2, result);
    }

    @isTest
    static void asObject() {
        Account acc = new Account(Name = 'Test 1');

        insert acc;

        Account result = (Account) SOQL.of(Account.SObjectType).asObject();

        Assert.areEqual(acc.Id, result.Id);
    }

    @isTest
    static void asObjectCatchOutOfBounds() {
        Account result = (Account) SOQL.of(Account.SObjectType).asObject();

        Assert.areEqual(null, result);
    }

    @isTest
    static void asList() {
        List<Account> accounts = getAccount();

        insert accounts;

        List<Account> result = SOQL.of(Account.SObjectType).asList();

        Assert.areEqual(accounts.size(), result.size());
    }

    @isTest
    static void asAggregated() {
        List<Account> accounts = getAccount();

        insert accounts;

        List<AggregateResult> result = SOQL.of(Account.SObjectType).countAs(Account.Name, 'names').asAggregated();

        Assert.areEqual(accounts.size(), result[0].get('names'));
    }

    @isTest
    static void asInteger() {
        List<Account> accounts = getAccount();

        insert accounts;

        Integer result = SOQL.of(Account.SObjectType).count().asInteger();

        Assert.areEqual(accounts.size(), result);
    }

    @isTest
    static void asMap() {
        List<Account> accounts = getAccount();

        insert accounts;

        Map<Id, SObject> result = SOQL.of(Account.SObjectType).asMap();

        Assert.areEqual(accounts.size(), result.size());

        for (Account acc : accounts) {
            Assert.isNotNull(result.get(acc.Id));
        }
    }

    static List<Account> getAccount() {
        return new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };
    }

    @isTest
    static void preview() {
        SOQL.of(Account.SObjectType).preview().asList();
    }

    @isTest
    static void previewCount() {
        SOQL.of(Account.SObjectType).count().preview().asInteger();
    }
}
