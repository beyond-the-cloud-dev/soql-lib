---
sidebar_position: 20
---

# TypeOf

Construct a typeof clause with provided API.

```apex
SOQL.of(Event.SObjectType)
		.with(SOQL.TypeOf.of('What')
				.when(Account.sObjectType).then(Account.BillingState)
				.whenElse('Name')
		)
		.toList();
```

## Methods

The following are methods for `TypeOf`.

[**INIT**](#init)

- [`of(String ofField)`](#of)
- [`of(SObjectField ofField)`](#of)

[**WHEN**](#when)

- [`when(SObjectType whenObject)`](#whenObject)

[**THEN**](#then)

- [`then(SObjectField field)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2, SObjectField field3)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4)`](#then-field1---field5)
- [`then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#then-field1---field5)
- [`then(List<SObjectField> fields)`](#then-fields)
- [`then(String fields)`](#then-string-fields)
- [`then(String relationshipName, SObjectField field)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field, SObjectField field2)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field, SObjectField field2, SObjectField field3)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field, SObjectField field2, SObjectField field3, SObjectField field4)`](#then-related-field1---field5)
- [`then(String relationshipName, SObjectField field, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5)`](#then-related-field1---field5)
- [`then(String relationshipName, Iterable<SObjectField> fields)`](#then-related-fields)

[**ELSE**](#else)
- [`whenElse(List<String> fields)`](#else-fields)
- [`whenElse(String fields)`](#else-string-fields)

## INIT
### of

Constructs a `TypeOf`.

**Signature**

```apex
TypeOf SOQL.Type.of(String ofField)
// or
TypeOf SOQL.Type.of(SObjectField ofField)
```

**Example**

```sql
SELECT TYPEOF What
	WHEN Account THEN Name, BillingState
	WHEN Opportunity THEN Id
	ELSE Id, Name
	END
FROM Event
```
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

## WHEN

### when object

**Signature**

```apex
TypeOf when(SObjectType whenObject);
```

## THEN

### then field1 - field5

**Signature**

```apex
Typeof then(SObjectField field);
```
```apex
Typeof then(SObjectField field1, SObjectField field2);
```
```apex
Typeof then(SObjectField field1, SObjectField field2, SObjectField field3);
```
```apex
Typeof then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
```
```apex
Typeof then(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
```

### then fields

Use for more than 5 fields.

**Signature**

```apex
Typeof then(List<SObjectField> fields);
```

### then string fields

**NOTE!** With String Apex does not create reference to field. Use `SObjectField` whenever it possible. Method below should be only use for dynamic queries.

**Signature**

```apex
Typeof then(String fields);
```

### then related field1 - field5

Allows to add parent field.

**Signature**

```apex title="Single Related Field Method"
Typeof then(String relationshipName, SObjectField field)
```
```apex title="Two Related Fields Method"
Typeof then(String relationshipName, SObjectField field1, SObjectField field2);
```
```apex title="Three Related Fields Method"
Typeof then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3);
```
```apex title="Four Related Fields Method"
Typeof then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
```
```apex title="Five Related Fields Method"
Typeof then(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
```

### then related fields

Allows to add parent fields to a query.

Use for more than 5 parent fields.

**Signature**

```apex title="Method Signature"
Typeof then(String relationshipName, Iterable<SObjectField> fields)
```

## ELSE

### else fields

**Signature**

```apex title="Method Signature"
Typeof whenElse(Iterable<String> fields)
```

### else string fields

**Signature**

```apex title="Method Signature"
Typeof whenElse(String fields)
```