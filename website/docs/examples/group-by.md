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
        /*
        SELECT LeadSource
        FROM Lead
        GROUP BY LeadSource
        */
        return LeadSelector.Query
                .with(Lead.LeadSource)
                .groupBy(Lead.LeadSource)
                .asAggregated();
    }
}
```
