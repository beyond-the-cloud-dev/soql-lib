---
sidebar_position: 30
---

# Distance

Perform location based calculations.

```apex
SOQL.of(Account.SObjectType)
  .whereAre(
  	SOQL.Filter.with(
  		SOQL.Distance.of(Account.BillingAddress)
   			.between(72.0, -135.0)
     		.mi()
   	).lessThan(5)
  ).toList();
```

## Methods

The following are methods for `Distance`.

[**FIELDS**](#fields)

- [`of(SObjectField ofField)`](#of)
- [`of(String relationshipName, SObjectField ofField)`](#of)

[**COMPERATORS**](#comperators)

- [`between(Location loc)`](#between)
- [`between(Decimal latitude, Decimal longitude)`](#between)

[**UNITS**](#units)

- [`mi()`](#mi)
- [`km()`](#km)

## FIELDS
### of

- `DISTANCE(BillingAddress, GEOLOCATION(72.0,-136.0), 'mi')`

**Signature**

```apex
Distance of(SObjectField ofField)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0,-136.0), 'mi') < 5
```
```apex
SOQL.of(Account.SObjectType)
  .whereAre(
  	SOQL.Filter.with(
   		SOQL.Distance.of(Account.BillingAddress)
     	.between(72.0,-136.0)
      .mi()
   	).lessThan(5)
  )
  .toList();
```

## COMPERATORS

### between

- `DISTANCE(BillingAddress, GEOLOCATION(72.0,-136.0), 'mi')`

**Signature**

```apex
Distance between(Location loc)
Distance between(Decimal latitude, Decimal longitude)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0,-136.0), 'mi') < 5
```
```apex
Location loc = Location.newInstance(72.0,-136.0);
SOQL.of(Account.SObjectType)
  .whereAre(
  	SOQL.Filter.with(
   		SOQL.Distance.of(Account.BillingAddress)
     	.between(loc)
      .mi()
   	).lessThan(5)
  )
  .toList();
```

## UNITS

### mi

Return the distance in miles.

**Signature**

```apex
Distance mi()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0,-136.0), 'mi') < 5
```
```apex
SOQL.of(Account.SObjectType)
  .whereAre(
  	SOQL.Filter.with(
   		SOQL.Distance.of(Account.BillingAddress)
     	.between(72.0,-136.0)
      .mi()
   	).lessThan(5)
  )
  .toList();
```

### km

Return the distance in kilometers.

**Signature**

```apex
Distance km()
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0,-136.0), 'km') < 5
```
```apex
SOQL.of(Account.SObjectType)
  .whereAre(
  	SOQL.Filter.with(
   		SOQL.Distance.of(Account.BillingAddress)
     	.between(72.0,-136.0)
      .km()
   	).lessThan(5)
  )
  .toList();
```
