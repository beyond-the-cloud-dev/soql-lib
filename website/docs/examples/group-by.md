---
sidebar_position: 7
---

# GROUP BY

Group of records instead of processing many individual records.

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
```
```apex
public inherited sharing class LeadSelector {

    public static SOQL query {
        get {
            return SOQL.of(Lead.SObjectType);
        }
    }
}

public with sharing class MyController {

    public static List<AggregateResult> getGroupedLeads() {
        return LeadSelector.query
                .with(Lead.LeadSource)
                .groupBy(Lead.LeadSource)
                .toAggregated();
    }
}
```
