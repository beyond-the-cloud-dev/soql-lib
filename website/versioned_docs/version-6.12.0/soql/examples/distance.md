---
sidebar_position: 30
---

# DISTANCE

For more details check [SOQL API - DISTANCE](../api/soql-distance.md).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.

## FILTER

**SOQL**

```sql title="Traditional SOQL"
SELECT Id
FROM Contact
WHERE DISTANCE(MailingAddress, GEOLOCATION(72.0, -136.0), 'mi') < 5
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Contact.MailingAddress)
            .between(72.0, -136.0)
            .mi()
    ).lessThan(5))
    .toList();
```

## ORDERING

**SOQL**

```sql title="Traditional SOQL"
SELECT Id
FROM Contact
ORDER BY DISTANCE(MailingAddress, GEOLOCATION(72.0, -136.0), 'mi')
```

**SOQL Lib**

```apex title="SOQL Lib Approach"
SOQL.of(Contact.SObjectType)
    .orderBy(
        SOQL.Distance.of(Contact.MailingAddress)
            .between(72.0, -136.0)
            .mi()
    )
    .toList();
```
