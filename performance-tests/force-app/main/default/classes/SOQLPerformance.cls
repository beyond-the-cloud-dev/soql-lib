public with sharing class SOQLPerformance {
    public static void simpleQuery(Integer iterations) {
        Decimal startTime = Limits.getCpuTime();

        for (Integer i = 0; i < iterations; i++) {
            SOQL.of(Account.SObjectType).toString();
        }

        Decimal endTime = Limits.getCpuTime();

        logResult('Simple Query', SOQL.of(Account.SObjectType).toString(), startTime, endTime, iterations);
    }

    public static void queryWithMultipleFields(Integer iterations) {
        Decimal startTime = Limits.getCpuTime();

        for (Integer i = 0; i < iterations; i++) {
            SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
                .toString();
        }

        Decimal endTime = Limits.getCpuTime();

        logResult(
            'Query with multiple fields',
            SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
                .toString(),
            startTime,
            endTime,
            iterations
        );
    }

    public static void queryWithSingleFilter(Integer iterations) {
        Decimal startTime = Limits.getCpuTime();

        for (Integer i = 0; i < iterations; i++) {
            SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
                .whereAre(SOQL.Filter.with(Account.Name).equal('Acme'))
                .toString();
        }

        Decimal endTime = Limits.getCpuTime();

        logResult(
            'Query with single condition',
            SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
                .whereAre(SOQL.Filter.with(Account.Name).equal('Acme'))
                .toString(),
            startTime,
            endTime,
            iterations
        );
    }

    public static void queryWithMultipleConditions(Integer iterations) {
        Decimal startTime = Limits.getCpuTime();

        for (Integer i = 0; i < iterations; i++) {
            SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
                .whereAre(SOQL.Filter.with(Account.Name).equal('Acme'))
                .toString();
        }

        Decimal endTime = Limits.getCpuTime();

        logResult(
            'Query with single condition',
            SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
                .whereAre(SOQL.Filter.with(Account.Name).equal('Acme'))
                .toString(),
            startTime,
            endTime,
            iterations
        );
    }

    public static void logResult(String testName, String query, Decimal startTime, Decimal endTime, Integer iterations) {
        Decimal duration = endTime - startTime;
        System.debug(testName + ' | ' + query + ' | ' + iterations + ' | ' + duration + ' ms' + ' | ' + duration / iterations + ' ms');
    }
}
