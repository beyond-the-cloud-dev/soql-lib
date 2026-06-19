---
sidebar_position: 40
---

# TYPEOF

For more details check Check [SOQL API - TypeOf](../api/soql-typeof.md).

> **NOTE! 🚨**
> All examples use inline queries built with the SOQL Lib Query Builder.
> If you are using a selector, replace `SOQL.of(...)` with `YourSelectorName.query()`.


**SOQL**

```sql
SELECT TYPEOF What
	WHEN Account THEN Name, BillingState
	WHEN Opportunity THEN Id
	ELSE Id, Name
	END
FROM Event
```

**SOQL Lib**

```apex
SOQL.of(Event.sObjectType)
	.with(
		SOQL.Type.of('What')
			.when(Account.sObjectType)
			.then(
				Account.Name,
				Account.BillingState
			)
			.when(Opporunity.sObjectType)
			.then(
				Opportunity.Id
			)
			.whenElse(
				new Set<String>{
					'Id',
					'Name'
				}
			)
	)
	.toList();
```
