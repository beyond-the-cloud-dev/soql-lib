---
sidebar_position: 50
---

# USING SCOPE

For more details check Check [SOQL API - USING SCOPE](../../api/standard-soql/soql.md#using-scope).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## DELEGATED

**SOQL**

```sql
SELECT Id
FROM Task
USING SCOPE DELEGATED
```

**SOQL Lib**

```apex
SOQL.of(Task.SObjectType)
    .delegatedScope()
    .toList();
```

## MINE

**SOQL**

```sql
SELECT Id
FROM Account
USING SCOPE MINE
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .mineScope()
    .toList();
```

## MINE_AND_MY_GROUPS

**SOQL**

```sql
SELECT Id
FROM ProcessInstanceWorkItem
USING SCOPE MINE_AND_MY_GROUPS
```

**SOQL Lib**

```apex
SOQL.of(ProcessInstanceWorkItem.SObjectType)
    .mineAndMyGroupsScope()
    .toList();
```

## MY_TERRITORY

**SOQL**

```sql
SELECT Id
FROM Opportunity
USING SCOPE MY_TERRITORY
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .myTerritoryScope()
    .toList();
```

## MY_TEAM_TERRITORY

**SOQL**

```sql
SELECT Id
FROM Opportunity
USING SCOPE MY_TEAM_TERRITORY
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .myTeamTerritoryScope()
    .toList();
```
## TEAM

**SOQL**

```sql
SELECT Id
FROM Account
USING SCOPE TEAM
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .teamScope()
    .toList();
```
