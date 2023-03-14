---
sidebar_position: 7
---

# GROUP BY

```apex
public inherited sharing class QS_Lead {

    public static QS Selector {
        get {
            return QS.of(Lead.sObjectType);
        }
    }
}

public with sharing class MyController {

    public static List<AggregateResult> getGroupedLeads() {
        return QS_Lead.Selector
                .fields(new List<sObjectField>{
                    Lead.LeadSource
                });
                .groupBy(Lead.LeadSource)
                .asAggregated();
    }
}
```
