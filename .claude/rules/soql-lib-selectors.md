---
paths:
  - "**/SOQL_*.cls"
---

# SOQL Lib — Selector Rules

## Always use the SOQL_<ObjectName> naming convention

```apex
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector { ... }
public inherited sharing class SOQL_Opportunity extends SOQL implements SOQL.Selector { ... }
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
// CORRECT
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

## Use .ignoreWhen() for optional filter parameters

```apex
// WRONG
public SOQL_Account byIndustry(String industry) {
    if (industry != null) {
        whereAre(Filter.with(Account.Industry).equal(industry));
    }
    return this;
}

// CORRECT
public SOQL_Account byIndustry(String industry) {
    whereAre(Filter.with(Account.Industry).equal(industry).ignoreWhen(industry == null));
    return this;
}
```

## Always call selector filter methods before SOQL Lib methods at call-site

```apex
// WRONG
SOQL_Account.query().with(Account.Phone).byType('Customer').toList();

// CORRECT
SOQL_Account.query().byType('Customer').with(Account.Phone).toList();
```
