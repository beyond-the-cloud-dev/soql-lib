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

Never pass raw strings to `whereAre()` unless the condition is fully dynamic and cannot be expressed via `SOQL.Filter`.

```apex
// WRONG
.whereAre('Industry = \'Technology\'')

// CORRECT
.whereAre(SOQL.Filter.with(Account.Industry).equal('Technology'))
```

## Always use .ignoreWhen() for optional filters

Never use conditional `if` blocks to decide whether to add a filter. Use `.ignoreWhen()` instead.

```apex
// WRONG
if (industry != null) {
    query.whereAre(SOQL.Filter.with(Account.Industry).equal(industry));
}

// CORRECT
.whereAre(SOQL.Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null))
```

## Always use .asDateLiteral() for date literal values

Date literal strings (e.g. `THIS_MONTH`, `LAST_N_DAYS:30`) cannot be bound and must use `.asDateLiteral()`.

```apex
.whereAre(SOQL.Filter.with(Opportunity.CloseDate).equal('THIS_MONTH').asDateLiteral())
```

## Choose the correct result method

| Goal | Use |
|---|---|
| Multiple records | `.toList()` |
| Single record | `.toObject()` — returns `null` for 0 rows, never throws |
| Existence check | `.doExist()` |
| COUNT | `.toInteger()` |
| Map by record Id | `.toMap()` |
| Map by field | `.toMap(SObjectField)` or `.toIdMapBy(SObjectField)` |
| Aggregate | `.toAggregated()` — or `.toAggregatedProxy()` when mocking is needed |
| Batch | `.toQueryLocator()` |

Never assign `.toObject()` without null-checking the result.

## Security modes

- Selectors always set `.systemMode().withoutSharing()` in their constructor.
- Override to `.userMode()` only at call-site when FLS enforcement is explicitly required.
- Never call `.withSharing()` or `.withoutSharing()` without pairing with `.systemMode()`.
