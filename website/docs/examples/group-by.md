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
public inherited sharing class SOQL_Lead extends SOQL implements SOQL.Selector {
    public static SOQL_Lead query() {
        return new SOQL_Lead();
    }

    private SOQL_Lead() {
        super(Lead.SObjectType);
    }
}

public with sharing class MyController {

    public static List<AggregateResult> getGroupedLeads() {
        return SOQL_Lead.query()
            .with(Lead.LeadSource)
            .groupBy(Lead.LeadSource)
            .toAggregated();
    }
}
```
