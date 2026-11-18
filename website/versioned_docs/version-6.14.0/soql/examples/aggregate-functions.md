---
sidebar_position: 30
---

# AGGREGATE FUNCTIONS

For more details check [SOQL API - AGGREGATE FUNCTIONS](../api/soql.md#aggregate-functions).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## AVG

**SOQL**

```sql title="Traditional SOQL"
SELECT CampaignId, AVG(Amount) amount
FROM Opportunity
GROUP BY CampaignId
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.CampaignId)
    .avg(Opportunity.Amount, 'amount')
    .groupBy(Opportunity.CampaignId)
    .toAggregated();
```

## AVG Related Field

**SOQL**

```sql title="Traditional SOQL"
SELECT AVG(Opportunity.Amount)
FROM OpportunityLineItem
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
SOQL.of(OpportunityLineItem.SObjectType)
    .avg('Opportunity', Opportunity.Amount)
    .toAggregated();
```

## AVG Related Field with Alias

**SOQL**

```sql
SELECT AVG(Opportunity.Amount) amount
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .avg('Opportunity', Opportunity.Amount, 'amount')
    .toAggregated();
```

## SUM

**SOQL**

```sql
SELECT CampaignId, SUM(Amount) totalAmount
FROM Opportunity
GROUP BY CampaignId
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.CampaignId)
    .sum(Opportunity.Amount, 'totalAmount')
    .groupBy(Opportunity.CampaignId)
    .toAggregated();
```

## SUM Related Field

**SOQL**

```sql
SELECT SUM(Opportunity.Amount)
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .sum('Opportunity', Opportunity.Amount)
    .toAggregated();
```

## SUM Related Field with Alias

**SOQL**

```sql
SELECT SUM(Opportunity.Amount) totalAmount
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .sum('Opportunity', Opportunity.Amount, 'totalAmount')
    .toAggregated();
```

## MIN

**SOQL**

```sql
SELECT CampaignId, MIN(Amount) minAmount
FROM Opportunity
GROUP BY CampaignId
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.CampaignId)
    .min(Opportunity.Amount, 'minAmount')
    .groupBy(Opportunity.CampaignId)
    .toAggregated();
```

## MIN Related Field

**SOQL**

```sql
SELECT MIN(Opportunity.Amount)
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .min('Opportunity', Opportunity.Amount)
    .toAggregated();
```

## MIN Related Field with Alias

**SOQL**

```sql
SELECT MIN(Opportunity.Amount) minAmount
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .min('Opportunity', Opportunity.Amount, 'minAmount')
    .toAggregated();
```

## MAX

**SOQL**

```sql
SELECT CampaignId, MAX(Amount) maxAmount
FROM Opportunity
GROUP BY CampaignId
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.CampaignId)
    .max(Opportunity.Amount, 'maxAmount')
    .groupBy(Opportunity.CampaignId)
    .toAggregated();
```

## MAX Related Field

**SOQL**

```sql
SELECT MAX(Opportunity.Amount)
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .max('Opportunity', Opportunity.Amount)
    .toAggregated();
```

## MAX Related Field with Alias

**SOQL**

```sql
SELECT MAX(Opportunity.Amount) maxAmount
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .max('Opportunity', Opportunity.Amount, 'maxAmount')
    .toAggregated();
```

## COUNT

**SOQL**

```sql
SELECT CampaignId, COUNT(Id) totalRecords
FROM Opportunity
GROUP BY CampaignId
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .with(Opportunity.CampaignId)
    .count(Opportunity.Id, 'totalRecords')
    .groupBy(Opportunity.CampaignId)
    .toAggregated();
```

## COUNT Related Field

**SOQL**

```sql
SELECT COUNT(Opportunity.Id)
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .count('Opportunity', Opportunity.Id)
    .toAggregated();
```

## COUNT Related Field with Alias

**SOQL**

```sql
SELECT COUNT(Opportunity.Id) totalRecords
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .count('Opportunity', Opportunity.Id, 'totalRecords')
    .toAggregated();
```

## COUNT_DISTINCT

**SOQL**

```sql
SELECT COUNT_DISTINCT(AccountId) uniqueAccounts
FROM Opportunity
```

**SOQL Lib**

```apex
SOQL.of(Opportunity.SObjectType)
    .countDistinct(Opportunity.AccountId, 'uniqueAccounts')
    .toAggregated();
```

## COUNT_DISTINCT Related Field

**SOQL**

```sql
SELECT COUNT_DISTINCT(Opportunity.AccountId)
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .countDistinct('Opportunity', Opportunity.AccountId)
    .toAggregated();
```

## COUNT_DISTINCT Related Field with Alias

**SOQL**

```sql
SELECT COUNT_DISTINCT(Opportunity.AccountId) uniqueAccounts
FROM OpportunityLineItem
```

**SOQL Lib**

```apex
SOQL.of(OpportunityLineItem.SObjectType)
    .countDistinct('Opportunity', Opportunity.AccountId, 'uniqueAccounts')
    .toAggregated();
```
