---
sidebar_position: 80
---

# ORDER BY

For more details check Check [SOQL API - ORDER BY](../api/soql.md#order-by).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

Control the order of the query results.

## SObjectField Field

**SOQL**

```sql title="Traditional SOQL"
SELECT Id
FROM Account
ORDER BY Name DESC
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
SOQL.of(Account.SObjectType)
    .orderBy(Account.Name)
    .sortDesc()
    .toList();
```

## String Field

**SOQL**

```sql title="Traditional SOQL"
SELECT Id
FROM Account
ORDER BY Name DESC
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
SOQL.of(Account.SObjectType)
    .orderBy('Name')
    .sortDesc()
    .toList();
```

## Related Field

**SOQL**

```sql
SELECT Id
FROM Contact
ORDER BY Account.Name
```

**SOQL Lib**

```apex
SOQL.of(Contact.SObjectType)
    .orderBy('Account', Account.Name)
    .toList();
```

## COUNT

**SOQL**

```sql
SELECT Industry
FROM Account
GROUP BY Industry
ORDER BY COUNT(Industry) DESC NULLS LAST
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .with(Account.Industry)
    .groupBy(Account.Industry)
    .orderByCount(Account.Industry).sortDesc().nullsLast()
    .toAggregated();
```

## Multiple Fields

```sql
SELECT Id
FROM Account
ORDER BY CreatedDate DESC, Name DESC NULLS LAST
```

**SOQL Lib**

```apex
SOQL.of(Account.SObjectType)
    .orderBy(Account.CreatedDate)
    .sortDesc()
    .orderBy(Account.Name)
    .sortDesc()
    .nullsLast()
    .toList();
```
