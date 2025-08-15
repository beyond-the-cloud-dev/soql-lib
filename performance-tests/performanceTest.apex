Integer ITERATIONS = 5000;

// simpleQuery();
// queryWithMultipleFields();
// queryWithSingleFilter();
// queryWithMultipleFilters();
// queryWithAggregates();
// queryWithSubquery();
// queryWithOrderByAndLimit();
complexQuery();

void simpleQuery() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType).toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType).toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void queryWithMultipleFields() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
        .toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
            .toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void queryWithSingleFilter() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
        .whereAre(SOQL.Filter.with(Account.Name).equal('Acme'))
        .toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
            .whereAre(SOQL.Filter.with(Account.Name).equal('Acme'))
            .toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void queryWithMultipleFilters() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
        .whereAre(SOQL.FilterGroup
            .add(SOQL.Filter.with(Account.Name).equal('Acme'))
            .add(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
            .add(SOQL.Filter.with(Account.BillingCity).equal('San Francisco'))
            .add(SOQL.Filter.with(Account.AccountSource).equal('Web'))
            .add(SOQL.Filter.with(Account.BillingCity).equal('San Francisco'))
        )
        .toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity, Account.AccountSource, Account.AnnualRevenue)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).equal('Acme'))
                .add(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
                .add(SOQL.Filter.with(Account.BillingCity).equal('San Francisco'))
                .add(SOQL.Filter.with(Account.AccountSource).equal('Web'))
                .add(SOQL.Filter.with(Account.BillingCity).equal('San Francisco'))
            )
            .toString();
    }   
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void queryWithAggregates() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType)
        .count(Account.Id, 'totalAccounts')
        .avg(Account.AnnualRevenue, 'avgRevenue')
        .sum(Account.AnnualRevenue, 'totalRevenue')
        .groupBy(Account.AccountSource)
        .toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .count(Account.Id, 'totalAccounts')
            .avg(Account.AnnualRevenue, 'avgRevenue')
            .sum(Account.AnnualRevenue, 'totalRevenue')
            .groupBy(Account.AccountSource)
            .toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void queryWithSubquery() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name)
        .with(SOQL.SubQuery
            .of('Contacts')
            .with(Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email)
            .whereAre(SOQL.Filter.with(Contact.IsDeleted).isFalse())
            .orderBy(Contact.LastName)
            .setLimit(10)
        )
        .toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name)
            .with(SOQL.SubQuery
                .of('Contacts')
                .with(Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email)
                .whereAre(SOQL.Filter.with(Contact.IsDeleted).equal(false))
                .orderBy(Contact.LastName)
                .setLimit(10)
            )
            .toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void queryWithOrderByAndLimit() {
    PerformanceReport report = new PerformanceReport(SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name, Account.CreatedDate, Account.AnnualRevenue)
        .whereAre(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(0))
        .orderBy(Account.AnnualRevenue).sortDesc()
        .orderBy(Account.CreatedDate)
        .setLimit(100)
        .offset(10)
        .toString());

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.CreatedDate, Account.AnnualRevenue)
            .whereAre(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(0))
            .orderBy(Account.AnnualRevenue).sortDesc()
            .orderBy(Account.CreatedDate)
            .setLimit(100)
            .offset(10)
            .toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}

void complexQuery() {
    PerformanceReport report = new PerformanceReport( SOQL.of(Account.SObjectType)
        .with(Account.Id, Account.Name, Account.BillingCity, Account.BillingState, Account.BillingCountry)
        .with(Account.AccountSource, Account.AnnualRevenue, Account.NumberOfEmployees, Account.Industry)
        .with(Account.CreatedDate, Account.LastModifiedDate, Account.Type, Account.Rating)
        .with('Owner', User.FirstName, User.LastName, User.Email)
        .whereAre(SOQL.FilterGroup
            .add(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).contains('Tech'))
                .add(SOQL.Filter.with(Account.Industry).equal('Technology'))
                .anyConditionMatching()
            )
            .add(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
            .add(SOQL.Filter.with(Account.BillingCountry).isIn(new List<String>{'US', 'Canada', 'UK'}))
            .add(SOQL.Filter.with(Account.CreatedDate).greaterOrEqual(Date.today().addYears(-5)))
        )
        .orderBy(Account.AnnualRevenue).sortDesc()
        .orderBy(Account.Name)
        .setLimit(50)
        .toString());   

    report.measureReferenceLoopCpuTime(ITERATIONS);

    report.markTargetStartTime();
    report.startHeapSizeMeasurement();
    for (Integer i = 0; i < ITERATIONS; i++) {
        SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.BillingCity, Account.BillingState, Account.BillingCountry)
            .with(Account.AccountSource, Account.AnnualRevenue, Account.NumberOfEmployees, Account.Industry)
            .with(Account.CreatedDate, Account.LastModifiedDate, Account.Type, Account.Rating)
            .with('Owner', User.FirstName, User.LastName, User.Email)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.FilterGroup
                    .add(SOQL.Filter.with(Account.Name).contains('Tech'))
                    .add(SOQL.Filter.with(Account.Industry).equal('Technology'))
                    .anyConditionMatching()
                )
                .add(SOQL.Filter.with(Account.AnnualRevenue).greaterThan(1000000))
                .add(SOQL.Filter.with(Account.BillingCountry).isIn(new List<String>{'US', 'Canada', 'UK'}))
                .add(SOQL.Filter.with(Account.CreatedDate).greaterOrEqual(Date.today().addYears(-5)))
            )
            .orderBy(Account.AnnualRevenue).sortDesc()
            .orderBy(Account.Name)
            .setLimit(50)
            .toString();
    }
    report.endHeapSizeMeasurement();
    report.markTargetEndTime();

    report.report(ITERATIONS);
}