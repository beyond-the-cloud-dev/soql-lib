# SOQL Lib — Selector Rules

## Always use the SOQL_<ObjectName> naming convention

```apex
// CORRECT
public inherited sharing class SOQL_Account extends SOQL implements SOQL.Selector { ... }
public inherited sharing class SOQL_Opportunity extends SOQL implements SOQL.Selector { ... }
```

## Always follow this exact class structure

Every selector must have these five elements in order:

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

## Always declare the MOCK_ID constant as @TestVisible

```apex
// CORRECT
@TestVisible
private static final String MOCK_ID = 'SOQL_Account';

// WRONG — not accessible from tests
private static final String MOCK_ID = 'SOQL_Account';
```

The constant value must exactly match the class name string.

## Always return the selector type from filter methods, not Queryable

```apex
// WRONG — caller loses access to selector-specific methods
public Queryable byType(String type) {
    whereAre(Filter.with(Account.Type).equal(type));
    return this;
}

// CORRECT
public SOQL_Account byType(String type) {
    whereAre(Filter.with(Account.Type).equal(type));
    return this;
}
```

## Always call selector filter methods before SOQL Lib methods

```apex
// WRONG
SOQL_Account.query().with(Account.Phone).byType('Customer').toList();

// CORRECT — selector methods first, then SOQL Lib overrides
SOQL_Account.query().byType('Customer').with(Account.Phone).toList();
```

## Never add WHERE conditions directly in the constructor

Default fields and security settings belong in the constructor. Filtering logic belongs in named filter methods.

```apex
// WRONG
private SOQL_Account() {
    super(Account.SObjectType);
    with(Account.Id, Account.Name);
    whereAre(Filter.with(Account.IsDeleted).isFalse()); // not in constructor
    systemMode();
    withoutSharing();
    mockId(MOCK_ID);
}

// CORRECT — expose as a named method
public SOQL_Account activeOnly() {
    whereAre(Filter.with(Account.IsActive__c).isTrue());
    return this;
}
```

## Use .ignoreWhen() for optional parameters in filter methods

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
