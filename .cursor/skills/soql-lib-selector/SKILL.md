---
name: soql-lib-selector
description: >-
  Creates Salesforce Apex selector classes using the SOQL Lib selector pattern.
  Covers class declaration (extends SOQL, implements SOQL.Selector), constructor
  defaults, static query() factory, domain-specific filter methods, and naming
  conventions (SOQL_<ObjectName>).
  Use when creating a new selector class, adding filter methods to an existing selector,
  or when asked how to encapsulate SOQL queries in a reusable class.
---

# SOQL Lib — Selector Pattern

A selector is a dedicated Apex class that encapsulates all queries for one SObject. It extends `SOQL`, implements `SOQL.Selector`, and exposes domain-specific filter methods.

## When to Use

- Use this skill when creating a new selector class for any SObject
- Use this skill when adding or refactoring filter methods on an existing selector
- Use this skill when asked how to structure or call a SOQL Lib query class

## Instructions

### Class structure rules

| Rule | Value |
|---|---|
| Class name | `SOQL_<ObjectApiName>` |
| Sharing keyword | `inherited sharing` |
| Extends | `SOQL` |
| Implements | `SOQL.Selector` |
| Constructor visibility | `private` |
| Mock ID constant | `@TestVisible private static final String MOCK_ID = 'SOQL_<ClassName>'` |
| Filter method return type | The selector class (e.g. `SOQL_Account`), **not** `Queryable` |
| Default security | `.systemMode().withoutSharing()` in constructor |

### Constructor checklist

```apex
private SOQL_Account() {
    super(Account.SObjectType);      // 1. required
    with(Account.Id, Account.Name);  // 2. default SELECT fields
    systemMode();                    // 3. ignore FLS in selector layer
    withoutSharing();                // 4. sharing enforced at service layer
    mockId(MOCK_ID);                 // 5. enable unit test mocking
}
```

### Filter method patterns

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

### Calling the selector

Selectors methods always should be called first, then other methods.

```apex
// Basic
List<Account> accounts = SOQL_Account.query().toList();

// Chained filters
List<Account> accounts = SOQL_Account.query()
    .byType('Customer')
    .byIndustry('Technology')
    .with(Account.Phone)
    .toList();

// Add extra fields beyond constructor defaults
List<Account> accounts = SOQL_Account.query()
    .with(Account.BillingCity, Account.Phone)
    .toList();

// Override security ad-hoc
List<Account> accounts = SOQL_Account.query()
    .userMode()
    .toList();

// Map result
Map<Id, Account> accountMap = (Map<Id, Account>) SOQL_Account.query()
    .byIds(accountIds)
    .toMap();

// Single record (null-safe)
Account acc = (Account) SOQL_Account.query()
    .byId(accountId)
    .toObject();
```

## Examples

### Minimal selector

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'SOQL_Account';

    public static SOQL_Account query() {
        return new SOQL_Account();
    }

    private SOQL_Account() {
        super(Account.SObjectType);
        with(Account.Id, Account.Name);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Account byType(String type) {
        whereAre(Filter.with(Account.Type).equal(type));
        return this;
    }

    public SOQL_Account byOwnerId(Id ownerId) {
        whereAre(Filter.with(Account.OwnerId).equal(ownerId));
        return this;
    }
}
```

### Complete selector

```apex
public inherited sharing class SOQL_Opportunity extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'SOQL_Opportunity';

    public static SOQL_Opportunity query() {
        return new SOQL_Opportunity();
    }

    private SOQL_Opportunity() {
        super(Opportunity.SObjectType);
        with(Opportunity.Id, Opportunity.Name, Opportunity.StageName, Opportunity.CloseDate, Opportunity.Amount);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Opportunity byStageName(String stageName) {
        whereAre(Filter.with(Opportunity.StageName).equal(stageName));
        return this;
    }

    public SOQL_Opportunity byAccountId(Id accountId) {
        whereAre(Filter.with(Opportunity.AccountId).equal(accountId).ignoreWhen(accountId == null));
        return this;
    }

    public SOQL_Opportunity byAccountIds(Set<Id> accountIds) {
        whereAre(Filter.with(Opportunity.AccountId).isIn(accountIds));
        return this;
    }

    public SOQL_Opportunity closingThisMonth() {
        whereAre(Filter.with(Opportunity.CloseDate).equal('THIS_MONTH').asDateLiteral());
        return this;
    }

    public SOQL_Opportunity isOpen() {
        whereAre(Filter.with(Opportunity.IsClosed).isFalse());
        return this;
    }

    public SOQL_Opportunity aboveAmount(Decimal minAmount) {
        whereAre(Filter.with(Opportunity.Amount).greaterOrEqual(minAmount));
        return this;
    }
}
```

### Selector with parent fields

```apex
public inherited sharing class SOQL_Contact extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'SOQL_Contact';

    public static SOQL_Contact query() {
        return new SOQL_Contact();
    }

    private SOQL_Contact() {
        super(Contact.SObjectType);
        with(Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email);
        with('Account', Account.Name, Account.Industry);
        systemMode();
        withoutSharing();
        mockId(MOCK_ID);
    }

    public SOQL_Contact byAccountId(Id accountId) {
        whereAre(Filter.with(Contact.AccountId).equal(accountId));
        return this;
    }
}
```
