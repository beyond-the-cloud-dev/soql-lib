---
paths:
  - "**/SOQL_*.cls"
---

# SOQL Lib — Selector Rules

## Always use the SOQL_<ObjectName> naming convention

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector { ... }
```

## Always follow this exact class structure

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {

    @TestVisible
    private static final String MOCK_ID = 'SOQL_Account';  // 1. mock ID = class name

    public static SOQL_Account query() {                   // 2. static factory
        return new SOQL_Account();
    }

    private SOQL_Account() {                               // 3. private constructor
        super(Account.SObjectType);                        //    a. SObjectType
        with(Account.Id, Account.Name);                    //    b. default fields
        systemMode();                                      //    c. security
        withoutSharing();                                  //    d. sharing
        mockId(MOCK_ID);                                   //    e. mock ID
    }
}
```

Never make the constructor `public`. Never skip `mockId(MOCK_ID)`.

## Always declare MOCK_ID as @TestVisible

```apex
@TestVisible
private static final String MOCK_ID = 'SOQL_Account';
```

The constant value must exactly match the class name string.

## Always return the selector type from filter methods, not Queryable

```apex
// WRONG
public Queryable byType(String type) { ... }

// CORRECT
public SOQL_Account byType(String type) { ... }
```

## Never add WHERE conditions in the constructor

Filtering logic belongs in named filter methods, not the constructor.

## Filter method patterns

```apex
// Equality
public SOQL_Account byType(String type) {
    whereAre(Filter.with(Account.Type).equal(type));
    return this;
}

// Null-safe — filter skipped when value is null
public SOQL_Account byIndustry(String industry) {
    whereAre(Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null));
    return this;
}

// IN
public SOQL_Account byOwnerIds(Set<Id> ownerIds) {
    whereAre(Filter.with(Account.OwnerId).isIn(ownerIds));
    return this;
}

// Boolean
public SOQL_Account activeOnly() {
    whereAre(Filter.with(Account.IsActive__c).isTrue());
    return this;
}

// Date literal
public SOQL_Opportunity closingThisMonth() {
    whereAre(Filter.with(Opportunity.CloseDate).equal('THIS_MONTH').asDateLiteral());
    return this;
}

// Range
public SOQL_Opportunity aboveAmount(Decimal minAmount) {
    whereAre(Filter.with(Opportunity.Amount).greaterOrEqual(minAmount));
    return this;
}
```

## Use .ignoreWhen() for optional filter parameters

```apex
// CORRECT
public SOQL_Account byIndustry(String industry) {
    whereAre(Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null));
    return this;
}
```

## Always call selector filter methods before SOQL Lib methods at call-site

```apex
// CORRECT — selector methods first, then SOQL Lib overrides
SOQL_Account.query().byType('Customer').with(Account.Phone).userMode().toList();
```

## Calling patterns

```apex
// Add extra fields beyond constructor defaults
SOQL_Account.query().with(Account.BillingCity, Account.Phone).toList();

// Override security at call-site (e.g. from a controller)
SOQL_Account.query().userMode().toList();

// Map result keyed by Id
Map<Id, Account> byId = (Map<Id, Account>) SOQL_Account.query().byIds(ids).toMap();

// Single record (null-safe — returns null for 0 rows)
Account acc = (Account) SOQL_Account.query().byId(accountId).toObject();

// Extract Ids of a related field
Set<Id> ownerIds = SOQL_Account.query().toIdsOf(Account.OwnerId);
```

## Use .anyConditionMatching() at call-site for top-level OR logic

```apex
SOQL_Account.query()
    .byIndustry('IT')
    .byRecordType('Partner')
    .anyConditionMatching()  // WHERE Industry = 'IT' OR RecordType.DeveloperName = 'Partner'
    .toList();
```
