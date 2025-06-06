Integer ITERATIONS = 10000;

// SOQLPerformance.simpleQuery(ITERATIONS);
// SOQLPerformance.queryWithMultipleFields(ITERATIONS);
SOQLPerformance.queryWithSingleFilter(ITERATIONS);

// SOQLPerformance.measure(
//     'Simple Query',
//     SOQL.of(Account.SObjectType),
//     ITERATIONS
// );

// SOQLPerformance.measure(
//     'Query with multiple fields',
//     SOQL.of(Account.SObjectType)
//         .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue),
//     ITERATIONS
// );

// SOQLPerformance.measure(
//     'Query with single condition',
//     SOQL.of(Account.SObjectType)
//         .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
//         .whereAre(SOQL.Filter.with(Account.Name).equal('Acme')),
//     ITERATIONS
// );

SOQLPerformance.measure(
    'Query with multiple conditions',
    SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
        .whereAre(SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.Name).equal('Acme'))
            .add(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
            .add(SOQL.Filter.with(Account.BillingCity).equal('San Francisco'))
            .add(SOQL.Filter.with(Account.AccountSource).equal('Web')
        )),
    ITERATIONS
);
