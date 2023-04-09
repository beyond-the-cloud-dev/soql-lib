---
sidebar_position: 7
---

# GROUP BY

```sql
SELECT LeadSource
FROM Lead
GROUP BY LeadSource
```
```apex
public inherited sharing class LeadSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Lead.sObjectType);
        }
    }
}

public with sharing class MyController {

    public static List<AggregateResult> getGroupedLeads() {
        return LeadSelector.Query
                .with(Lead.LeadSource)
                .groupBy(Lead.LeadSource)
                .asAggregated();
    }
}
```
