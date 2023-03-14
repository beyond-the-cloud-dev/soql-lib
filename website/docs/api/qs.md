---
sidebar_position: 1
---

# QS

## of

Conctructs an `QS`.

**Signature**

```apex
static QS of(sObjectType ofObject)
```

**Example**

```apex
QS.of(Account.sObjectType)
QS.of(Contact.sObjectType)
```

## fields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

> `SELECT` statement that specifies the fields to query. The fieldList in the `SELECT` statement specifies the list of one or more fields, separated by commas, that you want to retrieve.

**Signature**

```apex
QS fields(List<sObjectField> fields)
```

**Example**

```apex
QS.of(Account.sObjectType).fields(List<sObjectField>{
    Account.Id,
    Account.Name,
    Account.Industry
})

QS.of(Contact.sObjectType).fields(List<sObjectField>{
    Contact.Id,
    Contact.FirstName,
    Contact.LastName
})
```

## relatedFields

[SELECT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_fields.htm)

Allows to add parent field to a query.

**Signature**

```apex
QS relatedFields(String relationshipPath, List<sObjectField> fields)
```

**Example**

```apex
QS.of(Account.sObjectType).relatedFields('CreatedBy', List<sObjectField>{
    User.Id,
    User.Name
})

QS.of(Contact.sObjectType).relatedFields('Account', List<sObjectField>{
    Account.Id,
    Account.Name
})
```

## count

**Signature**

```apex
QS count()
```

**Example**

```apex

```

## countAs

**Signature**

```apex
countAs(sObjectField field, String alias)
```

**Example**

```apex
```

## subQuery

**Signature**

```apex
QS subQuery(QB_Sub subQuery)
```

**Example**

```apex
```

## scope

[USING SCOPE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm)

### delegatedScope

> Filter for records delegated to another user for action. For example, a query could filter for only delegated Task records.

**Signature**

```apex
QS delegatedScope()
```

**Example**

```apex
QS.of(Task.sObjectType).delegatedScope()
```

### mineScope

> Filter for records owned by the user running the query.

**Signature**

```apex
QS mineScope()
```

**Example**

```apex
QS.of(Account.sObjectType).mineScope()
```

### mineAndMyGroupsScope

> Filter for records assigned to the user running the query and the user’s queues. If a user is assigned to a queue, the user can access records in the queue. This filter applies only to the ProcessInstanceWorkItem object.

**Signature**

```apex
QS mineAndMyGroupsScope()
```

**Example**

```apex
QS.of(ProcessInstanceWorkItem.sObjectType).mineAndMyGroupsScope()
```

### myTerritoryScope

> Filter for records in the territory of the user running the query. This option is available if territory management is enabled for your organization.

**Signature**

```apex
QS myTerritoryScope()
```

**Example**

```apex
```

### myTeamTerritoryScope

> Filter for records in the territory of the team of the user running the query. This option is available if territory management is enabled for your organization.

**Signature**

```apex
QS myTeamTerritoryScope()
```

**Example**

```apex
```

### teamScope

> Filter for records assigned to a team, such as an Account team.

**Signature**

```apex
QS teamScope()
```

**Example**

```apex
QS.of(Account.sObjectType).teamScope()
```

## whereAre

**Signature**

```apex
QS whereAre(QB_ConditionClause conditions)
```

**Example**

```apex
```

## group by

### groupBy

**Signature**

```apex
QS groupBy(sObjectField field)
```

**Example**

```apex
```

### groupByRollup

**Signature**

```apex
QS groupByRollup(sObjectField field)
```

**Example**

```apex
```

### groupByCube

**Signature**

```apex
QS groupByCube(sObjectField field)
```

**Example**

```apex
```

## order by

[ORDER BY](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_orderby.htm)

### orderBy

> Use the optional `ORDER BY` in a `SELECT` statement of a SOQL query to control the order of the query results.

**Signature**

```apex
QS orderBy(sObjectField field)
```

**Example**

```apex
QS.of(Account.sObjectType).orderBy(Account.Name)
```

### orderByRelated

Order SOQL query by parent field.

**Signature**

```apex
QS orderByRelated(String path, sObjectField field)
```

**Example**

```apex
QS.of(Contact.sObjectType).orderByRelated('Account', Account.Name)
```

### sortDesc

Default order is ascending (`ASC`).

**Signature**

```apex
QS sortDesc()
```

**Example**

```apex
QS.of(Account.sObjectType).orderBy(Account.Name).sortDesc()
```

### nullsLast

By default, null values are sorted first (`NULLS FIRST`).

**Signature**

```apex
QS nullsLast()
```

**Example**

```apex
QS.of(Account.sObjectType).orderBy(Account.Industry).nullsLast()
```

## setLimit

- [LIMIT](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_limit.htm)

> `LIMIT` is an optional clause that can be added to a `SELECT` statement of a SOQL query to specify the maximum number of rows to return.

**Signature**

```apex
QS setLimit(Integer amount)
```

**Example**

```apex
QS.of(Account.sObjectType).setLimit(100)
```

## setOffset

- [OFFSET](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_offset.htm)

> When expecting many records in a query’s results, you can display the results in multiple pages by using the `OFFSET` clause on a SOQL query.

**Signature**

```apex
QS setOffset(Integer startingRow)
```

**Example**

```apex
QS.of(Account.sObjectType).setOffset(10)
```

## for

- [FOR VIEW and FOR REFERENCE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_view_for_reference.htm)
- [FOR UPDATE](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_update.htm)
### forReference

> Use to notify Salesforce when a record is referenced from a custom interface, such as in a mobile application or from a custom page.

**Signature**

```apex
QS forReference()
```

**Example**

```apex
QS.of(Contact.sObjectType).forReference()
```

### forView

> Use to update objects with information about when they were last viewed.

**Signature**

```apex
QS forView()
```

**Example**

```apex
QS.of(Contact.sObjectType).forView()
```

### forUpdate

> Use to lock sObject records while they’re being updated in order to prevent race conditions and other thread safety problems.

**Signature**

```apex
QS forUpdate()
```

**Example**

```apex
QS.of(Contact.sObjectType).forUpdate()
```

### allRows

**Signature**

```apex
QS allRows()
```

**Example**

```apex
```

## fls

[AccessLevel Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_AccessLevel.htm#apex_class_System_AccessLevel)

By default AccessLevel is set as `USER_MODE`.

### systemMode

> Execution mode in which the the object and field-level permissions of the current user are ignored, and the record sharing rules are controlled by the class sharing keywords.

**Signature**

```apex
QS systemMode()
```

**Example**

```apex
QS.of(Account.sObjectType).systemMode()
QS.of(Contact.sObjectType).userMode()
```

## sharing

[Using the with sharing, without sharing, and inherited sharing Keywords](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

### withSharing

Execute query `with sharing`

**Signature**

```apex
QS withSharing()
```

**Example**

```apex
QS.of(Account.sObjectType).withSharing()
QS.of(Contact.sObjectType).withSharing()
```

### withoutSharing

Execute query `without sharing`

**Signature**

```apex
QS withoutSharing()
```

**Example**

```apex
QS.of(Account.sObjectType).withoutSharing()
QS.of(Contact.sObjectType).withoutSharing()
```

## mocking

**Signature**

```apex
QS mocking(String queryIdentifier)
```

**Example**

```apex
```

## preview

**Signature**

```apex
QS preview()
```

**Example**

```apex
QS.of(Account.sObjectType).preview()
QS.of(Contact.sObjectType).preview()
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

**Signature**

```apex
sObject asObject()
```

**Example**

```apex
```

### asList

**Signature**

```apex
List<sObject> asList()
```

**Example**

```apex
```

### asAggregated

**Signature**

```apex
List<AggregateResult> asAggregated()
```

**Example**

```apex
```

### asInteger

**Signature**

```apex
Integer asInteger()
```

**Example**

```apex
```
