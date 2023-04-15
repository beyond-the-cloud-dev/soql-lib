---
sidebar_position: 1
---

# SOQL

## of

Conctructs an `SOQL`.

**Signature**

```apex
SOQL of(SObjectType ofObject)
```

**Example**

```sql
SELECT Id FROM Account
```
```apex
SOQL.of(Account.SObjectType).asList();
```

## select

### with field

**Signature**

```apex
SOQL with(SObjectField field)
```

**Example**

```sql
SELECT Id, Name
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(Account.Id)
    .with(Account.Name)
    .asList();
```

### with fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

> `SELECT` statement that specifies the fields to query. The fieldList in the `SELECT` statement specifies the list of one or more fields, separated by commas, that you want to retrieve.

**Signature**

```apex
SOQL with(List<SObjectField> fields)
```

**Example**

```sql
SELECT Id, Name, Industry
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(List<SObjectField>{
        Account.Id, Account.Name, Account.Industry
    }).asList();
```

### with string fields

**NOTE!** Apex do not have reference to String fields. Use it only for corner cases.

**Signature**

```apex
SOQL with(String fields)
```

**Example**

```sql
SELECT Id, Name, Industry
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with('Id, Name, Industry')
    .asList();
```

### with related fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

Allows to add parent field to a query.

**Signature**

```apex
SOQL with(String relationshipName, List<SObjectField> fields)
```

**Example**

```sql
SELECT CreatedBy.Id, CreatedBy.Name
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with('CreatedBy', List<SObjectField>{
        User.Id, User.Name
    }).asList();
```

### with subquery

[Using Relationship Queries](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_relationships_query_using.htm)

> Use SOQL to query several relationship types.

For more details check [`SOQL.SubQuery`](soql-sub.md) class.

**Signature**

```apex
SOQL with(SOQL.SubQuery subQuery)
```

**Example**

```sql
SELECT Id, (
    SELECT Id, Name
    FROM Contacts
) FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(new List<SObjectField>{
            Contact.Id, Contact.Name
        })
    ).asList();
```

### count

[COUNT()](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_count.htm#count_section_title)

> `COUNT()` returns the number of rows that match the filtering conditions.

**Signature**

```apex
SOQL count()
```

**Example**

```sql
SELECT COUNT()
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .count()
    .asInteger();
```

### countAs

[COUNT(fieldName)](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_count.htm#count_section_title)

> `COUNT(fieldName)` returns the number of rows that match the filtering conditions and have a non-null value for fieldName.

**Signature**

```apex
countAs(SObjectField field, String alias)
```

**Example**

```sql
SELECT COUNT(Name) names FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .countAs(Account.Name, 'names')
    .asAggregated();
```

## scope

[USING SCOPE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm)

### delegatedScope

> Filter for records delegated to another user for action. For example, a query could filter for only delegated Task records.

**Signature**

```apex
SOQL delegatedScope()
```

**Example**

```sql
SELECT Id
FROM Task
USING SCOPE DELEGATED
```
```apex
SOQL.of(Task.SObjectType)
    .delegatedScope()
    .asList();
```

### mineScope

> Filter for records owned by the user running the query.

**Signature**

```apex
SOQL mineScope()
```

**Example**

```sql
SELECT Id
FROM Task
USING SCOPE MINE
```
```apex
SOQL.of(Account.SObjectType)
    .mineScope()
    .asList();
```

### mineAndMyGroupsScope

> Filter for records assigned to the user running the query and the user’s queues. If a user is assigned to a queue, the user can access records in the queue. This filter applies only to the ProcessInstanceWorkItem object.

**Signature**

```apex
SOQL mineAndMyGroupsScope()
```

**Example**

```sql
SELECT Id
FROM Task
USING SCOPE MINE_AND_MY_GROUPS
```
```apex
SOQL.of(ProcessInstanceWorkItem.SObjectType)
    .mineAndMyGroupsScope()
    .asList();
```

### myTerritoryScope

> Filter for records in the territory of the user running the query. This option is available if territory management is enabled for your organization.

**Signature**

```apex
SOQL myTerritoryScope()
```

**Example**

```sql
SELECT Id
FROM Opportunity
USING SCOPE MY_TERRITORY
```
```apex
SOQL.of(Opportunity.SObjectType)
    .myTerritoryScope()
    .asList();
```

### myTeamTerritoryScope

> Filter for records in the territory of the team of the user running the query. This option is available if territory management is enabled for your organization.

**Signature**

```apex
SOQL myTeamTerritoryScope()
```

**Example**

```sql
SELECT Id
FROM Opportunity
USING SCOPE MY_TEAM_TERRITORY
```
```apex
SOQL.of(Opportunity.SObjectType)
    .myTeamTerritoryScope()
    .asList();
```

### teamScope

> Filter for records assigned to a team, such as an Account team.

**Signature**

```apex
SOQL teamScope()
```

**Example**

```sql
SELECT Id FROM Account USING SCOPE TEAM
```
```apex
SOQL.of(Account.SObjectType)
    .teamScope()
    .asList();
```

## whereAre

[WHERE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_conditionexpression.htm)

> The condition expression in a `WHERE` clause of a SOQL query includes one or more field expressions. You can specify multiple field expressions in a condition expression by using logical operators.

For more details check [`SOQL.FiltersGroup`](soql-filters-group.md) and [`SOQL.Filter`](soql-filter.md)

**Signature**

```apex
SOQL whereAre(FilterClause conditions)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id = :accountId OR Name = '%MyAccount%'
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(SOQL.Filter.with(Account.Id).equal(accountId))
        .add(SOQL.Filter.with(Account.Name).likeAny('MyAccount'))
        .conditionLogic('1 OR 2')
    ).asList();
```

### evaluate

Execute conditions passed as String.

**Signature**

```apex
SOQL whereAre(String conditions)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE NumberOfEmployees >=10 AND NumberOfEmployees <= 20
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre('NumberOfEmployees >=10 AND NumberOfEmployees <= 20')
    .asList();
```

## group by

[GROUP BY](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby.htm)
### groupBy

> You can use the `GROUP BY` option in a SOQL query to avoid iterating through individual query results. That is, you specify a group of records instead of processing many individual records.

**Signature**

```apex
SOQL groupBy(SObjectField field)
```

**Example**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .asAggregated();
```

### groupByRollup

**Signature**

```apex
SOQL groupByRollup(SObjectField field)
```

**Example**

```sql
SELECT LeadSource, COUNT(Name) cnt
FROM Lead
GROUP BY ROLLUP(LeadSource)
```
```apex
QS.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .countAs(Lead.Name, 'cnt')
    .groupByRollup(Lead.LeadSource)
    .asAggregated();
```

## order by

[ORDER BY](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_orderby.htm)

### orderBy

> Use the optional `ORDER BY` in a `SELECT` statement of a SOQL query to control the order of the query results.

**Signature**

```apex
SOQL orderBy(SObjectField field)
```

**Example**

```sql
SELECT Id
FROM Account
ORDER BY Name
```
```apex
SOQL.of(Account.SObjectType)
    .orderBy(Account.Name)
    .asList();
```

### orderBy related

Order SOQL query by parent field.

**Signature**

```apex
SOQL orderBy(String relationshipName, SObjectField field)
```

**Example**

```sql
SELECT Id
FROM Contact
ORDER BY Account.Name
```
```apex
SOQL.of(Contact.SObjectType)
    .orderBy('Account', Account.Name)
    .asList();
```

### sortDesc

Default order is ascending (`ASC`).

**Signature**

```apex
SOQL sortDesc()
```

**Example**

```sql
SELECT Id
FROM Account
ORDER BY Name DESC
```
```apex
SOQL.of(Account.SObjectType)
    .orderBy(Account.Name)
    .sortDesc()
    .asList();
```

### nullsLast

By default, null values are sorted first (`NULLS FIRST`).

**Signature**

```apex
SOQL nullsLast()
```

**Example**

```sql
SELECT Id
FROM Account
ORDER BY Name NULLS LAST
```
```apex
SOQL.of(Account.SObjectType)
    .orderBy(Account.Industry)
    .nullsLast()
    .asList();
```

## setLimit

- [LIMIT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_limit.htm)

> `LIMIT` is an optional clause that can be added to a `SELECT` statement of a SOQL query to specify the maximum number of rows to return.

**Signature**

```apex
SOQL setLimit(Integer amount)
```

**Example**

```sql
SELECT Id
FROM Account
LIMIT 100
```
```apex
SOQL.of(Account.SObjectType)
    .setLimit(100)
    .asList();
```

## offset

- [OFFSET](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_offset.htm)

> When expecting many records in a query’s results, you can display the results in multiple pages by using the `OFFSET` clause on a SOQL query.

**Signature**

```apex
SOQL offset(Integer startingRow)
```

**Example**

```sql
SELECT Id
FROM Account
OFFSET 10
```
```apex
SOQL.of(Account.SObjectType)
    .setOffset(10)
    .asList();
```

## for

- [FOR VIEW and FOR REFERENCE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_view_for_reference.htm)
- [FOR UPDATE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_update.htm)
### forReference

> Use to notify Salesforce when a record is referenced from a custom interface, such as in a mobile application or from a custom page.

**Signature**

```apex
SOQL forReference()
```

**Example**

```sql
SELECT Id
FROM Contact
FOR REFERENCE
```
```apex
SOQL.of(Contact.SObjectType)
    .forReference()
    .asList();
```

### forView

> Use to update objects with information about when they were last viewed.

**Signature**

```apex
SOQL forView()
```

**Example**

```sql
SELECT Id
FROM Contact
FOR VIEW
```
```apex
SOQL.of(Contact.SObjectType)
    .forView()
    .asList();
```

### forUpdate

> Use to lock sObject records while they’re being updated in order to prevent race conditions and other thread safety problems.

**Signature**

```apex
SOQL forUpdate()
```

**Example**

```sql
SELECT Id
FROM Contact
FOR UPDATE
```
```apex
SOQL.of(Contact.SObjectType)
    .forUpdate()
    .asList();
```

### allRows

> SOQL statements can use the ALL ROWS keywords to query all records in an organization, including deleted records and archived activities.

**Signature**

```apex
SOQL allRows()
```

**Example**

```sql
SELECT COUNT()
FROM Contact
ALL ROWS
```
```apex
SOQL.of(Contact.SObjectType)
    .count()
    .allRows()
    .asList();
```

## fls

[AccessLevel Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_AccessLevel.htm#apex_class_System_AccessLevel)

By default AccessLevel is set as `USER_MODE`.

### systemMode

> Execution mode in which the the object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the class sharing keywords.

**Signature**

```apex
SOQL systemMode()
```

**Example**

```apex
SOQL.of(Account.SObjectType)
    .systemMode()
    .asList();
```

## sharing

[Using the with sharing, without sharing, and inherited sharing Keywords](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

### withSharing

Execute query `with sharing`.

**Note!** System mode needs to be enabled by `.systemMode()`.

**Signature**

```apex
SOQL withSharing()
```

**Example**

```apex
SOQL.of(Account.SObjectType)
    .systemMode()
    .withSharing()
    .asList();
```

### withoutSharing

Execute query `without sharing`.

**Note!** System mode needs to be enabled by `.systemMode()`.

**Signature**

```apex
SOQL withoutSharing()
```

**Example**

```apex
SOQL.of(Account.SObjectType)
    .systemMode()
    .withoutSharing()
    .asList();
```

## mocking

### mockId

Query needs unique id that allows for mocking.

**Signature**

```apex
SOQL mockId(String queryIdentifier)
```

**Example**

```apex
SOQL.of(Account.SObjectType)
    .mockId('MyQuery')
    .asList();

// In Unit Test
SOQL.setMock('MyQuery', new List<Account>{
    new Account(Name = 'MyAccount 1'),
    new Account(Name = 'MyAccount 2')
});
```

### record mock

**Signature**

```apex
SOQL setMock(String mockId, SObject record)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .mockId('MyQuery')
    .asList();

// In Unit Test
SOQL.setMock('MyQuery', new Account(Name = 'MyAccount 1'));
```

### list mock

**Signature**

```apex
SOQL setMock(String mockId, List<SObject> records)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .mockId('MyQuery')
    .asList();

// In Unit Test
SOQL.setMock('MyQuery', new List<Account>{
    new Account(Name = 'MyAccount 1'),
    new Account(Name = 'MyAccount 2')
});
```

### count mock

**Signature**

```apex
SOQL setCountMock(String mockId, Integer amount)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .mockId('MyQuery')
    .count()
    .asInteger();

// In Unit Test
SOQL.setMock('MyQuery', 5);
```

### static resource mock

**Signature**

```apex
SOQL setMock(String mockId, String staticResource)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .mockId('MyQuery')
    .asList();

// In Unit Test
SOQL.setMock('MyQuery', 'MyStaticResource');
```

## preview

**Signature**

```apex
SOQL preview()
```

**Example**

```apex
SOQL.of(Account.SObjectType)
    .preview()
    .asList();
```

Query preview will be available in debug logs:

```
============ Query Preview ============
SELECT Name, AccountNumber, BillingCity, BillingCountry, BillingCountryCode
FROM Account
WHERE ((Id = :v1 OR Name LIKE :v2))
=======================================

============ Query Binding ============
{
  "v2" : "%Test%",
  "v1" : "0013V00000WNCw4QAH"
}
=======================================
```

## result

### asObject

When no records found. Instead of `List index out of bounds: 0` null will be returned.

**Signature**

```apex
sObject asObject()
```

**Example**

```apex
SOQL.of(Account.SObjectType).asObject();
```

### asList

**Signature**

```apex
List<sObject> asList()
```

**Example**

```apex
SOQL.of(Account.SObjectType).asList();
```

### asAggregated

**Signature**

```apex
List<AggregateResult> asAggregated()
```

**Example**


```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
```

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .asAggregated()
```

### asInteger

**Signature**

```apex
Integer asInteger()
```

**Example**

```sql
SELECT COUNT() FROM Account
```
```apex
QS.of(Account.SObjectType).count().asInteger();
```

### asMap

**Signature**

```apex
Map<Id, SObject> asMap()
```

**Example**

```apex
SOQL.of(Account.SObjectType).asMap();
```

### asQueryLocator

**Signature**

```apex
Database.QueryLocator asQueryLocator()
```

**Example**

```apex
SOQL.of(Account.SObjectType).asQueryLocator();
```

## predefined

For all predefined methods SOQL instance is returned so you can still adjust query before execution.
Add additional fields with [`.with`](#select).

### byId

**Signature**

```apex
SOQL byId(Id recordId)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id = '1234'
```
```apex
SOQL.of(Account.SObjectType)
    .byId('1234')
    .asObject();
```

### byIds

**Signature**

```apex
SOQL byIds(List<Id> recordIds)
```

```apex
SOQL byIds(Set<Id> recordIds)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id IN ('1234')
```
```apex
SOQL.of(Account.SObjectType)
    .byIds(new List<Id>{ '1234' })
    .asList();
```
```apex
SOQL.of(Account.SObjectType)
    .byIds(new Set<Id>{ '1234' })
    .asList();
```
