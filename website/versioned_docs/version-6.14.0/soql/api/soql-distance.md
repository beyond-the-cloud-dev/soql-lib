---
sidebar_position: 30
---

# Distance

Perform location based calculations.

```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Account.BillingAddress)
            .between(72.0, -135.0)
            .mi()
    ).lessThan(5))
    .toList();
```

## Methods

The following are methods for `Distance`.

[**FIELDS**](#fields)

- [`of(SObjectField ofField)`](#of-sobject-field)
- [`of(String relationshipName, SObjectField ofField)`](#of-related-field)

[**COMPERATORS**](#comperators)

- [`between(Location loc)`](#between-location)
- [`between(Decimal latitude, Decimal longitude)`](#between-latitude-longitude)

[**UNITS**](#units)

- [`mi()`](#mi)
- [`km()`](#km)

## FIELDS

### of sobject field

Specify the geolocation field used in the distance calculation.

**Signature**

```apex
Distance of(SObjectField ofField)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0, -136.0), 'mi') < 5
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Account.BillingAddress)
            .between(72.0, -136.0)
            .mi()
    ).lessThan(5))
    .toList();
```

### of related field

Specify a parent relationship geolocation field used in the distance calculation.

**Signature**

```apex
Distance of(String relationshipName, SObjectField ofField)
```

**Example**

```sql
SELECT Id
FROM Contact
WHERE DISTANCE(Account.BillingAddress, GEOLOCATION(72.0, -136.0), 'mi') < 5
```
```apex
SOQL.of(Contact.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of('Account', Account.BillingAddress)
            .between(72.0, -136.0)
            .mi()
    ).lessThan(5))
    .toList();
```

## COMPERATORS

### between location

Specify the target geolocation using a `Location` instance.

**Signature**

```apex
Distance between(Location loc)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0, -136.0), 'mi') < 5
```
```apex
Location loc = Location.newInstance(72.0, -136.0);

SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Account.BillingAddress)
            .between(loc)
            .mi()
    ).lessThan(5))
    .toList();
```

### between latitude longitude

Specify the target geolocation using latitude and longitude values.

**Signature**

```apex
Distance between(Decimal latitude, Decimal longitude)
```

**Example**

```sql
SELECT Id
FROM Account
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0, -136.0), 'mi') < 5
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Account.BillingAddress)
            .between(72.0, -136.0)
            .mi()
    ).lessThan(5))
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
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0, -136.0), 'mi') < 5
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Account.BillingAddress)
            .between(72.0, -136.0)
            .mi()
    ).lessThan(5))
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
WHERE DISTANCE(BillingAddress, GEOLOCATION(72.0, -136.0), 'km') < 5
```
```apex
SOQL.of(Account.SObjectType)
    .whereAre(SOQL.Filter.with(
        SOQL.Distance.of(Account.BillingAddress)
            .between(72.0, -136.0)
            .km()
    ).lessThan(5))
    .toList();
```
