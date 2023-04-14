/**
* PMD False Positives:
* - CyclomaticComplexity: It is a library and we tried to put everything into ONE test class
* - ApexUnitTestClassShouldHaveAsserts: PMD does not detect the Assert class
*/
@IsTest
private class SOQLTest {

    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static final Id FAKE_ACCOUNT_ID = '0013V00000WNCwCQAX';

    @IsTest
    static void count() {
        //Test
        String soql = SOQL.of(Account.SObjectType).count().toString();

        //Verify
        Assert.areEqual('SELECT COUNT() FROM Account', soql);
    }

    @IsTest
    static void countAs() {
         //Test
        String soql = SOQL.of(Account.SObjectType).countAs(Account.Name, 'names').toString();

         //Verify
        Assert.areEqual('SELECT COUNT(Name) names FROM Account', soql);
    }

    @IsTest
    static void withField() {
         //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(Account.Name)
            .with(Account.BillingCity)
            .toString();

        //Verify
        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withSetOfFields() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new Set<SObjectField>{
                Account.Name, Account.BillingCity
            }).toString();

        //Verify
        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withListOfFields() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name, Account.BillingCity
            }).toString();

        //Verify
        Assert.areEqual('SELECT Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withCommaSeparatedFields() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with('Id, Name, BillingCity')
            .toString();

        //Verify
        Assert.areEqual('SELECT Id, Name, BillingCity FROM Account', soql);
    }

    @IsTest
    static void withRelatedFields() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name, Account.BillingCity
            })
            .with('CreatedBy', new List<SObjectField>{
                User.Id, User.Name
            }).toString();

        //Verify
        Assert.areEqual('SELECT Name, BillingCity, CreatedBy.Id, CreatedBy.Name FROM Account', soql);
    }

    // SubQuery

    @IsTest
    static void subQueryField() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(Contact.Id)
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryFields() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryRelatedFields() {
        //Test
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
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM Contacts) FROM Account', soql);
    }

    @IsTest
    static void subQueryWhere() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .whereAre(SOQL.Filter.with(Contact.LastName).equal('Doe'))
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts WHERE LastName = :v1) FROM Account', soql);
    }

    @IsTest
    static void subQueryOrderBy() {
        //Test
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
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY Name DESC NULLS LAST) FROM Account', soql);
    }

    @IsTest
    static void subQueryOrderByRelated() {
        //Test
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
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts ORDER BY CreatedBy.Name DESC NULLS LAST) FROM Account', soql);
    }

    @IsTest
    static void subQuerySetLimit() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .setLimit(10)
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts LIMIT 10) FROM Account', soql);
    }

    @IsTest
    static void subQueryOffset() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .offset(100)
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts OFFSET 100) FROM Account', soql);
    }

    @IsTest
    static void subQueryForReference() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .forReference()
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR REFERENCE) FROM Account', soql);
    }

    @IsTest
    static void subQueryForView() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name
            })
            .with(SOQL.SubQuery.of('Contacts')
                .with(new List<SObjectField>{
                    Contact.Id, Contact.Name
                })
                .forView()
            ).toString();

        //Verify
        Assert.areEqual('SELECT Name , (SELECT Id, Name FROM Contacts FOR VIEW) FROM Account', soql);
    }

    @IsTest
    static void delegatedScope() {
        //Test
        String soql = SOQL.of(Task.SObjectType)
            .delegatedScope()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Task USING SCOPE DELEGATED', soql);
    }

    @IsTest
    static void mineScope() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .mineScope()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE MINE', soql);
    }

    @IsTest
    static void mineAndMyGroupsScope() {
        //Test
        String soql = SOQL.of(ProcessInstanceWorkItem.SObjectType)
            .mineAndMyGroupsScope()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM ProcessInstanceWorkitem USING SCOPE MINE_AND_MY_GROUPS', soql);
    }

    @IsTest
    static void myTerritoryScope() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .myTerritoryScope()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TERRITORY', soql);
    }

    @IsTest
    static void myTeamTerritoryScope() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .myTeamTerritoryScope()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE MY_TEAM_TERRITORY', soql);
    }

    @IsTest
    static void teamScope() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .teamScope()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account USING SCOPE TEAM', soql);
    }

    @IsTest
    static void id() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.id().isNotNull());

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void recordType() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.recordType().isNotNull());

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE RecordType.DeveloperName != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void withRelatedFieldFilter() {
        //Test
        SOQL builder = SOQL.of(Contact.SObjectType)
            .whereAre(SOQL.Filter.with('Account', Account.Name).equal('Test'));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Contact WHERE Account.Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @IsTest
    static void equalString() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).equal('Test'));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @IsTest
    static void notEqualString() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).notEqual('Test'));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
    }

    @IsTest
    static void lessThan() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThan(10));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees < :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void greaterThan() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThan(10));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees > :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void lessThanOrEqual() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).lessThanOrEqual(10));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees <= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void greaterThanOrEqual() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.NumberOfEmployees).greaterThanOrEqual(10));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(10, binding.get('v1'));
    }

    @IsTest
    static void likeAny() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).likeAny('Test'));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test%', binding.get('v1'));
    }

    @IsTest
    static void likeAnyLeft() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).likeAnyLeft('Test'));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('%Test', binding.get('v1'));
    }

    @IsTest
    static void likeAnyRight() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).likeAnyRight('Test'));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name LIKE :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test%', binding.get('v1'));
    }

    @IsTest
    static void isIn() {
        //Prepare
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isIn(names));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }


    @IsTest
    static void isNotIn() {
        //Prepare
        List<String> names = new List<String>{ 'Test 1', 'Test 2' };

        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{
                Account.Name, Account.BillingCity
            })
            .whereAre(SOQL.Filter.with(Account.Name).isNotIn(names));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Name, BillingCity FROM Account WHERE Name NOT IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(names, binding.get('v1'));
    }

    @IsTest
    static void isNotNull() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isNotNull());

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name != :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void isNull() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Name).isNull());

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Name = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(null, binding.get('v1'));
    }

    @IsTest
    static void conditionsGroup() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).equal('Test'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
            );

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
    }

    @IsTest
    static void nestedConditionsGroup() {
        //Test
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

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE (Name = :v1 AND BillingCity = :v2 AND (Name = :v3 OR BillingCity = :v4))', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('Test', binding.get('v1'));
        Assert.areEqual('Krakow', binding.get('v2'));
        Assert.areEqual('Test 2', binding.get('v3'));
        Assert.areEqual('Warsaw', binding.get('v4'));
    }

    @IsTest
    static void inInnerJoin() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).isIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
            ));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }


    @IsTest
    static void isNotInInnerJoin() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType)
            .whereAre(SOQL.Filter.with(Account.Id).isNotIn(
                SOQL.InnerJoin.of(Contact.SObjectType)
                    .with(Contact.AccountId)
                    .whereAre(SOQL.Filter.with(Contact.Name).equal('My Contact'))
            ));

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE Name = :v1)', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual('My Contact', binding.get('v1'));
    }

    @IsTest
    static void evaluateConditions() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre('NumberOfEmployees >= 10 AND NumberOfEmployees <= 20')
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account WHERE NumberOfEmployees >= 10 AND NumberOfEmployees <= 20', soql);
    }

    @IsTest
    static void evaluateEmptyConditions() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .whereAre('')
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account', soql);
    }

    @IsTest
    static void groupBy() {
        //Test
        String soql = SOQL.of(Lead.SObjectType)
            .with(new List<SObjectField>{
                Lead.LeadSource
            })
            .groupBy(Lead.LeadSource)
            .toString();

        //Verify
        Assert.areEqual('SELECT LeadSource FROM Lead GROUP BY LeadSource', soql);
    }

    @IsTest
    static void groupByRollup() {
        //Test
        String soql = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource)
            .countAs(Lead.Name, 'cnt')
            .groupByRollup(Lead.LeadSource)
            .toString();

        //Verify
        Assert.areEqual('SELECT LeadSource, COUNT(Name) cnt FROM Lead GROUP BY ROLLUP(LeadSource)', soql);
    }

    @IsTest
    static void orderBy() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .orderBy(Account.Industry).sortDesc().nullsLast()
            .orderBy(Account.Id)
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account ORDER BY Industry DESC NULLS LAST, Id ASC NULLS FIRST', soql);
    }

    @IsTest
    static void orderByRelated() {
        //Test
        String soql = SOQL.of(Contact.SObjectType)
            .orderBy('Account', Account.Name)
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Contact ORDER BY Account.Name ASC NULLS FIRST', soql);
    }


    @IsTest
    static void setLimit() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .setLimit(100)
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account LIMIT 100', soql);
    }

    @IsTest
    static void offset() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .offset(100)
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account OFFSET 100', soql);
    }

    @IsTest
    static void forReference() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .forReference()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account FOR REFERENCE', soql);
    }

    @IsTest
    static void forView() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .forView()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account FOR VIEW', soql);
    }

    @IsTest
    static void forUpdate() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .forUpdate()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account FOR UPDATE', soql);
    }

    @IsTest
    static void allRows() {
        //Test
        String soql = SOQL.of(Account.SObjectType)
            .allRows()
            .toString();

        //Verify
        Assert.areEqual('SELECT Id FROM Account ALL ROWS', soql);
    }

    @IsTest
    static void getById() {
        //Test
        SOQL builder = SOQL.of(Account.SObjectType).byId(FAKE_ACCOUNT_ID);

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id = :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(FAKE_ACCOUNT_ID, binding.get('v1'));
    }

    @IsTest
    static void byIdsSet() {
        Set<Id> accountIds = new Set<Id>{ FAKE_ACCOUNT_ID };

        SOQL builder = SOQL.of(Account.SObjectType).byIds(accountIds);

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(new List<Id>(accountIds), binding.get('v1'));
    }

    @IsTest
    static void byIdsList() {
        //Prepare
        List<Id> accountIds = new List<Id>{ FAKE_ACCOUNT_ID };

        //Test
        SOQL builder = SOQL.of(Account.SObjectType).byIds(accountIds);

        //Verify
        String soql = builder.toString();
        Assert.areEqual('SELECT Id FROM Account WHERE Id IN :v1', soql);

        Map<String, Object> binding = builder.binding();
        Assert.areEqual(accountIds, binding.get('v1'));
    }

    @IsTest
    static void withoutSharing() {
        //Prepare
        insertCases();

        System.runAs(standardUser()) {
            //Test
            List<Case> cases = SOQL.of(Case.SObjectType).systemMode().withoutSharing().asList();

            //Verify
            Assert.areEqual(2, cases.size());
        }
    }

    @IsTest
    static void withoutSharingCount() {
        //Prepare
        insertCases();

        System.runAs(standardUser()) {
            //Test
            Integer casesAmount = SOQL.of(Case.SObjectType).count().systemMode().withoutSharing().asInteger();

            //Verify
            Assert.areEqual(2, casesAmount);
        }
    }

    @IsTest
    static void withSharing() {
        //Prepare
        insertTasks();

        System.runAs(standardUser()) {
            //Test
            List<Task> tasks = SOQL.of(Task.SObjectType).systemMode().withSharing().asList();

            //Verify
            Assert.areEqual(0, tasks.size());
        }
    }

    @IsTest
    static void withSharingCount() {
        insertTasks();

        System.runAs(standardUser()) {
            //Test
            Integer tasksAmount = SOQL.of(Task.SObjectType).count().systemMode().withSharing().asInteger();

            //Verify
            Assert.areEqual(0, tasksAmount);
        }
    }

    @IsTest
    static void stripInaccessible() {
        //Prepare
        insertTasks();

        System.runAs(standardUser()) {
            //Test
            List<Task> tasks = SOQL.of(Task.SObjectType)
                .with(Task.Type)
                .systemMode()
                .stripInaccessible()
                .withoutSharing()
                .asList();

            Exception queryException = null;

            String inaccessibleFieldValue;

            try {
                inaccessibleFieldValue = tasks[0].Type;
            } catch(Exception e) {
                queryException = e;
            }

            //Verify
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

    @IsTest
    static void mockId() {
        //Prepare
        List<Account> accounts = getAccount();

        //Test
        SOQL.setMock('mockingQuery', accounts);
        List<Account> result = SOQL.of(Account.SObjectType).mockId('mockingQuery').asList();

        //Verify
        Assert.areEqual(accounts, result);
    }

    @IsTest
    static void mockingSingleRecord() {
        //Prepare
        Account testAccount = new Account(Name = 'Test 1');

        //Test
        SOQL.setMock('mockingQuery', testAccount);
        Account result = (Account) SOQL.of(Account.sObjectType).mockId('mockingQuery').asObject();

        //Verify
        Assert.areEqual(testAccount, result);
    }

    @IsTest
    static void mockingStaticResource() {
        List<Account> result;
        try {
             //Test
            SOQL.setMock('mockingQuery', 'testAccounts');
            result = SOQL.of(Account.sObjectType).mockId('mockingQuery').asList();
        } catch (Exception missingStaticResource) {
            //Verify
            Assert.isInstanceOfType(missingStaticResource, NullPointerException.class);
        }
    }

    @IsTest
    static void mockingCount() {
        //Test
        SOQL.setCountMock('mockingQuery', 2);
        Integer result = SOQL.of(Account.sObjectType).count().mockId('mockingQuery').asInteger();

        //Verify
        Assert.areEqual(2, result);
    }

    @IsTest
    static void asObject() {
        //Prepare
        Account acc = new Account(Name = 'Test 1');
        insert acc;

        //Test
        Account result = (Account) SOQL.of(Account.SObjectType).asObject();

        //Verify
        Assert.areEqual(acc.Id, result.Id);
    }

    @IsTest
    static void asObjectCatchOutOfBounds() {
        //Test
        Account result = (Account) SOQL.of(Account.SObjectType).asObject();

        //Verify
        Assert.areEqual(null, result);
    }

    @IsTest
    static void asList() {
        //Prepare
        List<Account> accounts = getAccount();
        insert accounts;

        //Test
        List<Account> result = SOQL.of(Account.SObjectType).asList();

        //Verify
        Assert.areEqual(accounts.size(), result.size());
    }

    @IsTest
    static void asAggregated() {
        //Prepare
        List<Account> accounts = getAccount();
        insert accounts;

        //Test
        List<AggregateResult> result = SOQL.of(Account.SObjectType).countAs(Account.Name, 'names').asAggregated();

        //Verify
        Assert.areEqual(accounts.size(), result[0].get('names'));
    }

    @IsTest
    static void asInteger() {
        //Prepare
        List<Account> accounts = getAccount();
        insert accounts;

        //Test
        Integer result = SOQL.of(Account.SObjectType).count().asInteger();

        //Verify
        Assert.areEqual(accounts.size(), result);
    }

    @IsTest
    static void asMap() {
        //Prepare
        List<Account> accounts = getAccount();
        insert accounts;

        //Test
        Map<Id, SObject> result = SOQL.of(Account.SObjectType).asMap();

        //Verify
        Assert.areEqual(accounts.size(), result.size());
        for (Account acc : accounts) {
            Assert.isNotNull(result.get(acc.Id));
        }
    }

    @IsTest
    static void asQueryLocator() {
        //Test
        Database.QueryLocator queryLocator = SOQL.of(Account.SObjectType)
            .with(Account.Id)
            .with(Account.Name)
            .asQueryLocator();


        //Verify
        Assert.areEqual('SELECT Id, Name FROM Account', queryLocator.getQuery());
    }

    static List<Account> getAccount() {
        return new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2')
        };
    }

    @IsTest
    static void preview() {
        //Test
        SOQL.of(Account.SObjectType).preview().asList();
    }

    @IsTest
    static void previewCount() {
        //Test
        SOQL.of(Account.SObjectType).count().preview().asInteger();
    }
}
