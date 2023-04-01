---
sidebar_position: 1
---

# SOQL

## of

Conctructs an `SOQL`.

**Signature**

```apex
SOQL of(sObjectType ofObject)
```

**Example**

```apex
//SELECT Id FROM Account
SOQL.of(Account.sObjectType).asList();

//SELECT Id FROM Contact
SOQL.of(Contact.sObjectType).asList();
```

## select

### with field

**Signature**

```apex
SOQL with(sObjectField field)
```

**Example**

```apex
//SELECT Id, Name FROM Account
SOQL.of(Account.sObjectType)
    .with(Account.Id)
    .with(Account.Name)
    .asList();

//SELECT Id, FirstName, LastName FROM Contact
SOQL.of(Contact.sObjectType)
    .with(Contact.Id)
    .with(Contact.FirstName)
    .with(Contact.LastName)
    .asList();
```

### with fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

> `SELECT` statement that specifies the fields to query. The fieldList in the `SELECT` statement specifies the list of one or more fields, separated by commas, that you want to retrieve.

**Signature**

```apex
SOQL with(List<sObjectField> fields)
```

**Example**

```apex
//SELECT Id, Name, Industry FROM Account
SOQL.of(Account.sObjectType)
    .with(List<sObjectField>{
        Account.Id,
        Account.Name,
        Account.Industry
    }).asList();

//SELECT Id, FirstName, LastName FROM Contact
SOQL.of(Contact.sObjectType)
    .with(List<sObjectField>{
        Contact.Id,
        Contact.FirstName,
        Contact.LastName
    }).asList();
```

### with string fields

**NOTE!** Apex do not have reference to String fields. Use it only for corner cases.

**Signature**

```apex
SOQL with(String fields)
```

**Example**

```apex
//SELECT Id, Name, Industry FROM Account
SOQL.of(Account.sObjectType)
    .with('Id, Name, Industry')
    .asList();

//SELECT Id, FirstName, LastName FROM Contact
SOQL.of(Contact.sObjectType)
    .with('Id, FirstName, LastName')
    .asList();
```

### with related fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

Allows to add parent field to a query.

**Signature**

```apex
SOQL with(String relationshipName, List<sObjectField> fields)
```

**Example**

```apex
//SELECT CreatedBy.Id, CreatedBy.Name FROM Account
SOQL.of(Account.sObjectType)
    .with('CreatedBy', List<sObjectField>{
        User.Id,
        User.Name
    }).asList();

//SELECT Account.Id, Account.Name FROM Contact
SOQL.of(Contact.sObjectType)
    .with('Account', List<sObjectField>{
        Account.Id,
        Account.Name
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

```apex
//SELECT Id, (SELECT Id, Name FROM Contacts) FROM Account
SOQL.of(Account.sObjectType)
    .with(SOQL.SubQuery.of('Contacts')
        .with(new List<sObjectField>{
            Contact.Id,
            Contact.Name
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

```apex
//SELECT COUNT() FROM Account
SOQL.of(Account.sObjectType)
    .count()
    .asInteger();
```

### countAs

[COUNT(fieldName)](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_count.htm#count_section_title)

> `COUNT(fieldName)` returns the number of rows that match the filtering conditions and have a non-null value for fieldName.

**Signature**

```apex
countAs(sObjectField field, String alias)
```

**Example**

```apex
//SELECT COUNT(Name) names FROM Account
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM Task USING SCOPE DELEGATED
SOQL.of(Task.sObjectType)
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

```apex
//SELECT Id FROM Account USING SCOPE MINE
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM ProcessInstanceWorkItem USING SCOPE MINE_AND_MY_GROUPS
SOQL.of(ProcessInstanceWorkItem.sObjectType)
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

```apex
//SELECT Id FROM X USING SCOPE MY_TERRITORY
```

### myTeamTerritoryScope

> Filter for records in the territory of the team of the user running the query. This option is available if territory management is enabled for your organization.

**Signature**

```apex
SOQL myTeamTerritoryScope()
```

**Example**

```apex
//SELECT Id FROM X USING SCOPE MY_TEAM_TERRITORY
```

### teamScope

> Filter for records assigned to a team, such as an Account team.

**Signature**

```apex
SOQL teamScope()
```

**Example**

```apex
//SELECT Id FROM Account USING SCOPE TEAM
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM Account WHERE Id = :accountId OR Name = '%MyAccount%'
SOQL.of(Account.sObjectType)
    .whereAre(SOQL.FiltersGroup
        .add(SOQL.Filter.with(Account.Id).equal(accountId))
        .add(SOQL.Filter.with(Account.Name).likeAny('MyAccount'))
        .conditionLogic('1 OR 2')
    ).asList();
```

## group by

[GROUP BY](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby.htm)
### groupBy

> You can use the `GROUP BY` option in a SOQL query to avoid iterating through individual query results. That is, you specify a group of records instead of processing many individual records.

**Signature**

```apex
SOQL groupBy(sObjectField field)
```

**Example**

```apex
//SELECT LeadSource FROM LEAD GROUP BY LeadSource
SOQL.of(Lead.sObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .asAggregated();
```

### groupByRollup

**Signature**

```apex
SOQL groupByRollup(sObjectField field)
```

**Example**

```apex
QS.of(Lead.sObjectType)
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
SOQL orderBy(sObjectField field)
```

**Example**

```apex
//SELECT Id FROM Account ORDER BY Name
SOQL.of(Account.sObjectType)
    .orderBy(Account.Name)
    .asList();
```

### orderByRelated

Order SOQL query by parent field.

**Signature**

```apex
SOQL orderByRelated(String path, sObjectField field)
```

**Example**

```apex
//SELECT Id FROM Contact ORDER BY Account.Name
SOQL.of(Contact.sObjectType)
    .orderByRelated('Account', Account.Name)
    .asList();
```

### sortDesc

Default order is ascending (`ASC`).

**Signature**

```apex
SOQL sortDesc()
```

**Example**

```apex
//SELECT Id FROM Account ORDER BY Name DESC
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM Account ORDER BY Name NULLS LAST
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM Account LIMIT 100
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM Account OFFSET 10
SOQL.of(Account.sObjectType)
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

```apex
//SELECT Id FROM Contact FOR REFERENCE
SOQL.of(Contact.sObjectType)
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

```apex
//SELECT Id FROM Contact FOR VIEW
SOQL.of(Contact.sObjectType)
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

```apex
//SELECT Id FROM Contact FOR UPDATE
SOQL.of(Contact.sObjectType)
    .forUpdate()
    .asList();
```

### allRows

**Signature**

```apex
SOQL allRows()
```

**Example**

```apex
//SELECT Id FROM X ALL ROWS
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
SOQL.of(Account.sObjectType)
    .systemMode()
    .asList();
```

## sharing

[Using the with sharing, without sharing, and inherited sharing Keywords](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

### withSharing

Execute query `with sharing`. System mode needs to be enabled.

**Signature**

```apex
SOQL withSharing()
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .systemMode()
    .withSharing()
    .asList();
```

### withoutSharing

Execute query `without sharing`. System mode needs to be enabled.

**Signature**

```apex
SOQL withoutSharing()
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .systemMode()
    .withoutSharing()
    .asList();
```

## mocking

**Signature**

```apex
SOQL mocking(String queryIdentifier)
```

**Example**

```apex
SOQL.of(Account.sObjectType)
    .mocking('MyQuery')
    .asList();

// In Unit Test
SOQL.setMock('MyQuery', new List<Account>{
    new Account(Name = 'MyAccount 1'),
    new Account(Name = 'MyAccount 2')
});
```

## preview

**Signature**

```apex
SOQL preview()
```

**Example**

```apex
SOQL.of(Account.sObjectType)
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
SOQL.of(Account.sObjectType).asObject();
```

### asList

**Signature**

```apex
List<sObject> asList()
```

**Example**

```apex
SOQL.of(Account.sObjectType).asList();
```

### asAggregated

**Signature**

```apex
List<AggregateResult> asAggregated()
```

**Example**

```apex
SOQL.of(Lead.sObjectType)
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

```apex
//SELECT COUNT() FROM Account
QS.of(Account.sObjectType).count().asInteger();
```
