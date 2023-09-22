---
sidebar_position: 1
---

# SOQL

The lib main class for query construction.

## Methods

The following are methods for `SOQL`.

[**INIT**](#init)

- [`of(SObjectType ofObject)`](#of)
- [`of(String ofObject)`](#of)

[**SELECT**](#select)

- [`with(SObjectField field)`](#with-fields)
- [`with(SObjectField field1, SObjectField field2)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#with-field1---field5)
- [`with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#with-field1---field5)
- [`with(List<SObjectField> fields)`](#with-fields)
- [`with(List<String> fields)`](#with-fields)
- [`with(String fields)`](#with-string-fields)
- [`with(String relationshipName, SObjectField field)`](#with-related-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2)`](#with-related-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3)`](#with-related-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#with-related-field1---field5)
- [`with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#with-related-field1---field5)
- [`with(String relationshipName, List<SObjectField> fields)`](#with-related-fields)

[**COUNT**](#count)

- [`count()`](#count)
- [`count(SObjectField field)`](#count-field)
- [`count(SObjectField field, String alias)`](#count-with-alias)

[**GROUPING**](#grouping)

- [`grouping(SObjectField field, String alias)`](#grouping)

[**SUBQUERY**](#sub-query)

- [`with(SubQuery subQuery)`](#with-subquery)

[**USING SCOPE**](#using-scope)

- [`delegatedScope()`](#delegatedscope)
- [`mineScope()`](#minescope)
- [`mineAndMyGroupsScope()`](#mineandmygroupsscope)
- [`myTerritoryScope()`](#myterritoryscope)
- [`myTeamTerritoryScope()`](#myteamterritoryscope)
- [`teamScope()`](#teamscope)

[**WHERE**](#where)

- [`whereAre(FilterGroup filterGroup)`](#whereare)
- [`whereAre(Filter filter)`](#whereare)
- [`conditionLogic(String order)`](#conditionlogic)
- [`anyConditionMatching()`](#anyconditionmatching);

[**GROUP BY**](#group-by)

- [`groupBy(SObjectField field)`](#group-by)
- [`groupByRollup(SObjectField field)`](#groupbyrollup)
- [`groupByCube(SObjectField field)`](#groupbycube)

[**ORDER BY**](#order-by)

- [`orderBy(SObjectField field)`](#order-by)
- [`orderBy(String field)`](#order-by)
- [`orderBy(String field, String direction)`](#order-by)
- [`orderBy(String relationshipName, SObjectField field)`](#orderby-related)
- [`sordDesc()`](#sortdesc)
- [`nullsLast()`](#nullslast)

[**LIMIT**](#limit)

- [`setLimit(Integer amount)`](#setlimit)

[**OFFSET**](#offset)

- [`offset(Integer startingRow)`](#offset)

[**FOR**](#for)

- [`forReference()`](#forreference)
- [`forView()`](#forview)
- [`forUpdate()`](#forupdate)
- [`allRows()`](#allrows)

[**FIELD-LEVEL SECURITY**](#field-level-security)

- [`systemMode()`](#systemmode)
- [`stripInaccessible()`](#stripinaccessible)
- [`stripInaccessible(AccessType accessType)`](#stripinaccessible)

[**SHARING MODE**](#sharing-mode)

- [`withSharing()`](#withsharing)
- [`withoutSharing()`](#withoutsharing)

[**MOCKING**](#mocking)

- [`mockId(String id)`](#mockid)

[**DEBUGGING**](#debugging)

- [`preview()`](#preview)

[**PREDEFINIED**](#predefinied)

- [`byId(SObject record)`](#byid)
- [`byId(Id recordId)`](#byid)
- [`byIds(Iterable<Id> recordIds)`](#byids)
- [`byIds(List<SObject> records)`](#byids)

[**RESULT**](#result)

- [`doExist()`](#doexist)
- [`toValueOf(SObjectField fieldToExtract)`](#tovalueof)
- [`toValuesOf(SObjectField fieldToExtract)`](#tovaluesof)
- [`toInteger()`](#tointeger)
- [`toObject()`](#toobject)
- [`toList()`](#tolist)
- [`toAggregated()`](#toaggregated)
- [`toMap()`](#tomap)
- [`toMap(SObjectField keyField)`](#tomap-with-custom-key)
- [`toAggregatedMap(SObjectField keyField)`](#toaggregatedmap)
- [`toQueryLocator()`](#toquerylocator)

## INIT
### of

Conctructs an `SOQL`.

**Signature**

```apex
SOQL of(SObjectType ofObject)
SOQL of(String ofObject)
```

**Example**

```sql
SELECT Id FROM Account
```
```apex
SOQL.of(Account.SObjectType).toList();

String ofObject = 'Account';
SOQL.of(ofObject).toList();
```

## SELECT

### with field1 - field5

**Signature**

```apex
SOQL with(SObjectField field)
```
```apex
SOQL with(SObjectField field1, SObjectField field2);
```
```apex
SOQL with(SObjectField field1, SObjectField field2, SObjectField field3);
```
```apex
SOQL with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
```
```apex
SOQL with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
```

**Example**

```sql
SELECT Id, Name
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .toList();

SOQL.of(Account.SObjectType)
    .with(Account.Id)
    .with(Account.Name)
    .toList();
```

### with fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

> `SELECT` statement that specifies the fields to query. The fieldList in the `SELECT` statement specifies the list of one or more fields, separated by commas, that you want to retrieve.

Use for more than 5 fields.

**Signature**

```apex
SOQL with(List<SObjectField> fields)
SOQL with(List<String> fields)
```

**Example**

```sql
SELECT Id, Name, Industry, AccountNumber, AnnualRevenue, BillingCity
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with(new List<SObjectField>{
        Account.Id,
        Account.Name,
        Account.Industry,
        Account.AccountNumber,
        Account.AnnualRevenue,
        Account.BillingCity
    }).toList();

SOQL.of(Account.SObjectType)
    .with(new List<String>{
        'Id',
        'Name',
        'Industry',
        'AccountNumber',
        'AnnualRevenue',
        'BillingCity'
    }).toList();
```

### with string fields

**NOTE!** With String Apex does not create reference to field. Use `SObjectField` whenever it possible. Method below should be only use for dynamic queries.

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
    .toList();
```

### with related field1 - field5

Allows to add parent field to a query.

**Signature**

```apex
SOQL with(String relationshipName, SObjectField field)
```
```apex
SOQL with(String relationshipName, SObjectField field1, SObjectField field2);
```
```apex
SOQL with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3);
```
```apex
SOQL with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
```
```apex
SOQL with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
```

**Example**

```sql
SELECT CreatedBy.Name
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with('CreatedBy', User.Name)
    .toList();

SOQL.of(Account.SObjectType)
    .with('CreatedBy', User.Id, User.Name, User.Phone)
    .toList();
```

### with related fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

Allows to add parent fields to a query.

Use for more than 5 parent fields.

**Signature**

```apex
SOQL with(String relationshipName, List<SObjectField> fields)
```

**Example**

```sql
SELECT
    CreatedBy.Id,
    CreatedBy.Name,
    CreatedBy.Phone,
    CreatedBy.FirstName,
    CreatedBy.LastName,
    CreatedBy.Email
FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .with('CreatedBy', new List<SObjectField>{
        User.Id,
        User.Name,
        User.Phone,
        User.FirstName,
        User.LastName,
        User.Email
    }).toList();
```

## SUB-QUERY

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
        .with(Contact.Id, Contact.Name)
    ).toList();
```

## COUNT-QUERY

### count

[COUNT()](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_count.htm#count_section_title)

> `COUNT()` returns the number of rows that match the filtering conditions.

**Note!** COUNT() must be the only element in the SELECT list, any other fields will be automatically removed.

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
    .toInteger();
```

### count field

**Signature**

```apex
count(SObjectField field)
```

**Note!** To avoid the `Field must be grouped or aggregated` error, any default fields will be automatically removed.

You can still specify additional fields, but they should be placed after the COUNT() function in the SELECT statement.

**Example**

```sql
SELECT COUNT(Id), COUNT(CampaignId)
FROM Opportunity
```
```apex
 SOQL.of(Opportunity.SObjectType)
    .count(Opportunity.Id)
    .count(Opportunity.CampaignId)
    .toAggregated();
```

### count with alias

**Signature**

```apex
count(SObjectField field, String alias)
```

**Note!** To avoid the `Field must be grouped or aggregated` error, any default fields will be automatically removed.

You can still specify additional fields, but they should be placed after the COUNT() function in the SELECT statement.

**Example**

```sql
SELECT COUNT(Name) names FROM Account
```
```apex
SOQL.of(Account.SObjectType)
    .count(Account.Name, 'names')
    .toAggregated();
```

## GROUPING

### grouping

**Signature**

```apex
grouping(SObjectField field, String alias)
```

**Example**

```sql
SELECT LeadSource, Rating,
    GROUPING(LeadSource) grpLS, GROUPING(Rating) grpRating,
    COUNT(Name) cnt
FROM Lead
GROUP BY ROLLUP(LeadSource, Rating)
```
```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource, Lead.Rating)
    .grouping(Lead.LeadSource, 'grpLS')
    .grouping(Lead.Rating, 'grpRating')
    .count(Lead.Name, 'cnt')
    .groupByRollup(Lead.LeadSource)
    .groupByRollup(Lead.Rating)
    .toAggregated();
```

## USING SCOPE

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
    .toList();
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
    .toList();
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
    .toList();
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
    .toList();
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
    .toList();
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
    .toList();
```

## WHERE

### whereAre

[WHERE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_conditionexpression.htm)

> The condition expression in a `WHERE` clause of a SOQL query includes one or more field expressions. You can specify multiple field expressions in a condition expression by using logical operators.

For more details check [`SOQL.FilterGroup`](soql-filters-group.md) and [`SOQL.Filter`](soql-filter.md)

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
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.Id).equal(accountId))
        .add(SOQL.Filter.with(Account.Name).contains('MyAccount'))
        .conditionLogic('1 OR 2')
    ).toList();
```

### whereAre string

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
    .toList();
```

### conditionLogic

Set conditions order for SOQL query. When not specify all conditions will be with `AND`.

**Signature**

```apex
SOQL conditionLogic(String order)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'Test' AND BillingCity = 'Krakow'
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).equal('Test'))
    .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
    .conditionLogic('1 OR 2')
    .toList();
```

### anyConditionMatching

When the [conditionLogic](#conditionlogic) is not specified, all conditions are joined using the `AND` operator by default.

To change the default condition logic, you can utilize the `anyConditionMatching` method, which joins conditions using the `OR` operator.

**Signature**

```apex
SOQL anyConditionMatching()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Name = 'Test' AND BillingCity = 'Krakow'
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(Account.Name).equal('Test'))
    .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
    .anyConditionMatching()
    .toList();
```

## GROUP BY

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
    .toAggregated();
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
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .count(Lead.Name, 'cnt')
    .groupByRollup(Lead.LeadSource)
    .toAggregated();
```

### groupByCube

**Signature**

```apex
SOQL groupByCube(SObjectField field)
```

**Example**

```sql
SELECT Type
FROM Account
GROUP BY ROLLUP(Type)
```
```apex
SOQL.of(Account.SObjectType)
    .with(Account.Type)
    .groupByCube(Account.Type)
    .toAggregated();
```

## ORDER BY

[ORDER BY](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_orderby.htm)

### orderBy

> Use the optional `ORDER BY` in a `SELECT` statement of a SOQL query to control the order of the query results.

**Signature**

```apex
SOQL orderBy(SObjectField field)
SOQL orderBy(String field)
SOQL orderBy(String field, String direction)
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
    .toList();

SOQL.of(Account.SObjectType)
    .orderBy('Name')
    .sortDesc()
    .toList();

SOQL.of(Account.SObjectType)
    .orderBy('Name', 'DESC')
    .toList();
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
    .toList();
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
    .toList();
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
    .toList();
```

## LIMIT
### setLimit

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
    .toList();
```

## OFFSET
### offset

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
    .toList();
```

## FOR

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
    .toList();
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
    .toList();
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
    .toList();
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
    .toList();
```

## FIELD-LEVEL SECURITY

[AccessLevel Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_AccessLevel.htm#apex_class_System_AccessLevel)

By default AccessLevel is set as `USER_MODE`.

More details you can find in [here](../advanced-usage/fls.md)

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
    .toList();
```

### stripInaccessible

`USER_MODE` enforces not only object and field-level security but also sharing rules (`with sharing`). You may encounter situations where you need object and field-level security but want to ignore sharing rules (`without sharing`). To achieve this, use `.systemMode()`, `.withoutSharing()` and `.stripInaccessible()`.

Read more about `stripInaccessible` in [advanced](../advanced-usage/fls.md#strip-inaccessible).

**Signature**

```apex
SOQL stripInaccessible()
SOQL stripInaccessible(AccessType accessType)
```

```apex
SOQL.of(Account.SObjectType)
    .systemMode()
    .withoutSharing()
    .stripInaccessible()
    .toList();
```

## SHARING MODE

[Using the with sharing, without sharing, and inherited sharing Keywords](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

More details you can find in [here](../advanced-usage/sharing.md).

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
    .toList();
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
    .toList();
```

## MOCKING

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
    .toList();

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
    .toList();

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
    .toList();

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
    .toInteger();

// In Unit Test
SOQL.setMock('MyQuery', 5);
```

## DEBUGGING
### preview

**Signature**

```apex
SOQL preview()
```

**Example**

```apex
SOQL.of(Account.SObjectType)
    .preview()
    .toList();
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

## PREDEFINIED

For all predefined methods SOQL instance is returned so you can still adjust query before execution.
Add additional fields with [`.with`](#select).

### byId

**Signature**

```apex
SOQL byId(Id recordId)
```

```apex
SOQL byId(SObject record)
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
    .toObject();
```
```apex
Account account = [SELECT Id FROM Account LIMIT 1];
SOQL.of(Account.SObjectType)
    .byId(account)
    .toList();
```

### byIds

**Signature**


```apex
SOQL byIds(Iterable<Id> recordIds)
```

```apex
SOQL byIds(List<SObject> records)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE Id IN ('1234')
```

```apex
SOQL.of(Account.SObjectType)
    .byIds(new Set<Id>{ '1234' })
    .toList();
```

```apex
SOQL.of(Account.SObjectType)
    .byIds(new List<Id>{ '1234' })
    .toList();
```

```apex
List<Account> accounts = [SELECT Id FROM Account];
SOQL.of(Account.SObjectType)
    .byIds(accounts)
    .toList();
```

## RESULT

### doExist

```apex
Boolean doExist()
```

**Example**

```apex
Boolean isRecordExist = SOQL.of(Account.SObjectType).byId('1234').doExist();
```

### toValueOf

Extract field value from query result.
Field will be automatically added to the query fields.

**Signature**

```apex
Object toValueOf(SObjectField fieldToExtract)
```

**Example**

```apex
String accountName = (String) SOQL.of(Account.SObjectType).byId('1234').toValueOf(Account.Name)
```

### toValuesOf

Extract field values from query result.
Field will be automatically added to the query fields.

SOQL Lib is using [Building a KeySet from any field](https://salesforce.stackexchange.com/questions/393308/get-a-list-of-one-column-from-a-soql-result) approach to get only one field.

Note! It does not work with Custom Metadata.

**Signature**

```apex
Set<String> toValuesOf(SObjectField fieldToExtract)
```

**Example**

```apex
Set<String> accountNames = SOQL.of(Account.SObjectType).byId('1234').toValuesOf(Account.Name)
```

### toInteger

**Signature**

```apex
Integer toInteger()
```

**Example**

```sql
SELECT COUNT() FROM Account
```
```apex
SOQL.of(Account.SObjectType).count().toInteger();
```

### toObject

When list of records is greater than 1 the `List has more than 1 row for assignment to SObject` will occur.

When there is no record to assign the `List has no rows for assignment to SObject` will occur.

**Signature**

```apex
sObject toObject()
```

**Example**

```apex
SOQL.of(Account.SObjectType).toObject();
```

### toList

**Signature**

```apex
List<sObject> toList()
```

**Example**

```apex
SOQL.of(Account.SObjectType).toList();
```

### toAggregated

**Signature**

```apex
List<AggregateResult> toAggregated()
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
    .toAggregated()
```

### toMap

**Signature**

```apex
Map<Id, SObject> toMap()
```

**Example**

```apex
SOQL.of(Account.SObjectType).toMap();
```

### toMap with custom key

**Signature**

```apex
Map<String, SObject> toMap(SObjectField keyField)
```

**Example**

```apex
Map<String, Account> nameToAccount = (Map<String, Account>) SOQL.of(Account.SObjectType).toMap(Account.Name);
```

### toAggregatedMap

**Signature**

```apex
Map<String, List<SObject>> toAggregatedMap(SObjectField keyField)
```

**Example**

```apex
Map<String, Account> industryToAccounts = SOQL.of(Account.SObjectType).toAggregatedMap(Account.Industry);
```

### toQueryLocator

**Signature**

```apex
Database.QueryLocator toQueryLocator()
```

**Example**

```apex
SOQL.of(Account.SObjectType).toQueryLocator();
```
