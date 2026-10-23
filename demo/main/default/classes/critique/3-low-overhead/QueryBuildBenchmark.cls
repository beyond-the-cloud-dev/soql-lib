public with sharing class QueryBuildBenchmark {
    public static Decimal averageBuildTimeMs(Integer iterations) {
        Integer startCpuTime = Limits.getCpuTime();
        for (Integer i = 0; i < iterations; i++) {
            buildComplexQuery();
        }
        return Decimal.valueOf(Limits.getCpuTime() - startCpuTime) / iterations;
    }

    private static String buildComplexQuery() {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{ Account.Id, Account.Name, Account.Industry, Account.Type, Account.BillingCity, Account.AnnualRevenue })
            .with('Owner', User.Name, User.Email)
            .with(SOQL.SubQuery.of('Contacts').with(Contact.Id, Contact.Name, Contact.Email))
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Industry).equal('Technology'))
                .add(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
                .add(SOQL.Filter.name().contains('Acme'))
                .anyConditionMatching()
            )
            .orderBy(Account.Name)
            .setLimit(100)
            .toString();
    }
}
