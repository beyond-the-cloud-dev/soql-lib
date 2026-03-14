---
paths:
  - "**/*.cls"
---

# SOQL Lib — Query Rules

## Never write raw SOQL

Never use inline SOQL brackets or `Database.query()`. Always use SOQL Lib.

```apex
// WRONG
List<Account> accounts = [SELECT Id, Name FROM Account WHERE Industry = :industry];
List<Account> accounts = Database.query('SELECT Id FROM Account');

// CORRECT
List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.Industry).equal(industry))
    .toList();
```

## Always prefer a selector over inline SOQL.of()

If a `SOQL_<ObjectName>` selector exists, use it. Create one if it is missing.

```apex
// WRONG — inline when a selector exists
SOQL.of(Account.SObjectType).with(Account.Id).toList();

// CORRECT
SOQL_Account.query().toList();
```

## Always use SObjectField tokens, never String field names

```apex
// WRONG
.with('Id, Name, Industry')

// CORRECT
.with(Account.Id, Account.Name, Account.Industry)
```

Only use `String` fields for truly dynamic field lists that cannot be known at compile time.

## Always use SOQL.Filter for WHERE conditions

```apex
// WRONG
.whereAre('Industry = \'Technology\'')

// CORRECT
.whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
```

## Always use .ignoreWhen() for optional filters

Never use `if` blocks to conditionally add a filter. Use `.ignoreWhen()` instead.

```apex
// WRONG
if (industry != null) {
    query.whereAre(SOQL.Filter.with(Account.Industry).equal(industry));
}

// CORRECT
.whereAre(SOQL.Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null))
```

## Always use .asDateLiteral() for date literal strings

```apex
.whereAre(SOQL.Filter.with(Opportunity.CloseDate).equal('THIS_MONTH').asDateLiteral())
.whereAre(SOQL.Filter.with(Account.CreatedDate).greaterThan('LAST_N_DAYS:30').asDateLiteral())
```

## Choose the correct result method

| Goal | Method |
|---|---|
| Multiple records | `.toList()` |
| Single record (null-safe) | `.toObject()` — returns `null` for 0 rows |
| Existence check | `.doExist()` |
| COUNT | `.toInteger()` |
| Map by record Id | `.toMap()` |
| Map by field | `.toMap(SObjectField)` or `.toIdMapBy(SObjectField)` |
| Aggregate (mockable) | `.toAggregatedProxy()` |
| Aggregate | `.toAggregated()` |
| Batch | `.toQueryLocator()` |

Never assign `.toObject()` without null-checking the result.

## Security modes

- Selectors default to `.systemMode().withoutSharing()` in their constructor.
- Override to `.userMode()` only at call-site when FLS enforcement is required.
- Never call `.withSharing()` or `.withoutSharing()` without pairing with `.systemMode()`.
