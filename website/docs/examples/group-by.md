---
sidebar_position: 7
---

# GROUP BY

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
                .with(new List<sObjectField>{
                    Lead.LeadSource
                });
                .groupBy(Lead.LeadSource)
                .asAggregated();
    }
}
```
