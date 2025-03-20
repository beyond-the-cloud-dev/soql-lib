---
sidebar_position: 7
---

# GROUP BY

For more details check Check [SOQL API - GROUP BY](../../api/standard-soql/soql.md#group-by).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

Group of records instead of processing many individual records.

## GROUP BY

### Field

**SOQL**

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
```

**SOQL Lib**

```apex
SOQL.of(Lead.SObjectType)
    .with(Lead.LeadSource)
    .groupBy(Lead.LeadSource)
    .toAggregated();
```

### Related Field

**SOQL**

```sql
SELECT COUNT(Name) count
FROM OpportunityLineItem
GROUP BY OpportunityLineItem.Opportunity.Account.Id
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .count(OpportunityLineItem.Name, 'count')
    .groupBy('OpportunityLineItem.Opportunity.Account', Account.Id)
    .toAggregated();
```

## GROUP BY ROLLUP

### Field

**SOQL**

```sql
SELECT COUNT(Name) cnt
FROM Lead
GROUP BY ROLLUP(ConvertedOpportunity.StageName)
```

**SOQL Lib**

```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name, 'cnt')
    .groupByRollup('ConvertedOpportunity', Opportunity.StageName)
    .toAggregated();
```


### Related Field

**SOQL**

```sql
SELECT Type
FROM Account
GROUP BY ROLLUP(Type)
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Type)
    .groupByCube(Account.Type)
    .toAggregated();
```

## GROUP BY CUBE

### Field

**SOQL**

```sql
SELECT Type
FROM Account
GROUP BY CUBE(Type)
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Type)
    .groupByCube(Account.Type)
    .toAggregated();
```

### Related Field

**SOQL**

```sql
SELECT COUNT(Name) cnt
FROM Lead
GROUP BY CUBE(ConvertedOpportunity.StageName)
```

**SOQL Lib**

```apex
SOQL.of(Lead.SObjectType)
    .count(Lead.Name, 'cnt')
    .groupByCube('ConvertedOpportunity', Opportunity.StageName)
    .toAggregated();
```
