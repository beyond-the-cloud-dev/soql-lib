# SOQL Lib Critique

## SOQL Lib is More Complex Than Traditional SOQL
_aka "I have to learn a new syntax"_

### Use SOQL Evaluator

SOQL Lib has 3 different modules: [SOQL](/soql/getting-started), [SOQL Cache](/cache/getting-started), and [SOQL Evaluator](/evaluator/getting-started). SOQL Evaluator was created for developers who don't want to learn a new syntax but still want to benefit from features like mocking and result functions. You can use [this module](https://github.com/beyond-the-cloud-dev/soql-lib/tree/main/force-app/main/default/classes/main/soql-evaluator) without switching to an entirely new syntax.

```apex
Set<Id> accountIds = SOQLEvaluator.of([SELECT Id FROM Account]).toIds();
List<String> accountNames = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toValuesOf(Account.Name);
```

### It's Not That Complicated

#### Documentation

SOQL Lib provides comprehensive online documentation with the [playground](/playground) and numerous [examples](/soql/examples/select). You can also use the search feature in the top-right corner to find what you're looking for. The Fluent API was designed to stay as close to traditional SOQL syntax as possible. However, due to Apex's `Identifier name is reserved` restriction, some keywords like `select`, `where`, and `limit` couldn't be used.

#### Interfaces

"Do I need to go to the documentation and spend a lot of time searching for what I need?"

No. At the top of [SOQL.cls](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls), we've placed all the interfaces you can interact with. Even as the author, I don't remember all the methods. However, I can quickly navigate to [SOQL.cls](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls) and identify what I need in seconds. Everything important is at the top—you don't have to scroll through the entire class searching for methods. Just focus on the interfaces.

#### Use AI

A simple prompt in your IDE integrated with AI can be very helpful: "Based on SOQL.cls and SOQL_Test.cls, understand how SOQL Lib works. Write an inline query that returns all accounts with Employee Number greater than 100." Voilà! That's it. You don't need to read documentation or check interfaces manually. 

### Less Complicated Than Traditional SOQL

#### Result Functions

SOQL Lib provides numerous [result functions](/soql/examples/result) that make your code easier to read and understand. Most operations you typically perform on SOQL results are available as methods in SOQL Lib. Instead of repeating the same transformations throughout your codebase, simply use result methods.

**Apex**

```apex
Map<String, List<Account>> industryToAccounts = new Map<String, List<Account>>();

for (Account acc : [SELECT Id, Name, Industry FROM Account]) {
    if (!industryToAccounts.containsKey(acc.Industry)) {
        industryToAccounts.put(acc.Industry, new List<Acccount>());
    }

    industryToAccounts.get(acc.Industry).put(acc);
}
```

**SOQL Lib**

```apex
Map<String, List<Account>> industryToAccounts = (Map<String, List<Account>>) SOQL.of(Account.SObjectType)
    .toAggregatedMap(Account.Industry);
```

#### Dynamic Query Builder

Without SOQL Lib, approximately 90% of your queries use traditional SOQL. The remaining 10% need to be dynamic, requiring numerous string operations. Your code typically looks like this:

```apex
String accountName = '';

String query = 'SELECT Id, Name WHERE BillingCity = \'Krakow\'';

if (String.isNotEmpty(accountName)) {
    query += ' AND Name LIKE \'%' + accountName +'\%';
}

query += ' FROM Account';

Database.query(query);
```

This code is difficult to read and maintain. With SOQL Lib, you can refactor it to:

```apex
String accountName = '';

SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.FilterGroup
        .add(SOQL.Filter.with(Account.BillingCity).equal('Krakow'))
        .add(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    )
    .toList();
```

This is much easier to read. Additionally, the `ignoreWhen` function automatically checks if accountName is empty and ignores the condition accordingly—no more if statements cluttering your code.

## Additional Processing Time

SOQL Lib builds a query string and passes it to the `Database.queryWithBinds` method. How long do you think it takes to build a string like `SELECT Id, Name FROM Account`?

Not much. While dynamic code can be CPU-intensive, we've run extensive performance tests (full results coming soon). Here's a preview:

Building a complex query dynamically with SOQL Lib consumes less than **2ms**, and around **1ms** for simple queries.
Even if you execute 100 complex queries in one transaction (101 SOQL queries per synchronous transaction), in the worst-case scenario, SOQL Lib uses only ~200ms out of the 10,000ms CPU limit available.

### Result Functions

Additionally, SOQL Lib can be faster than your own implementation. We perform internal optimizations for certain result functions. 
For instance:

```apex
Set<String> accountNames = new Set<String>();

for (Account acc : [SELECT Name FROM Account]) {
    accountNames.add(acc.Name);
}
```

The SOQL Lib version is approximately 2x faster because we use internal aggregation optimizations. Learn more about this technique: https://salesforce.stackexchange.com/questions/393308/get-a-list-of-one-column-from-a-soql-result

```apex
Set<String> accountNames = SOQL.of(Account.SObjectType).toValuesOf(Account.Name);
```

### Mocking

How long it takes to run Apex Unit Tests with all test data inserted? I think seconds, or even minutes.
How long it takes to run Apex Unit Tests when query results are mocked and there is no need to create a test data? miliseconds to seconds, but for sure not minutes. 

I wouldn't mentioned the benefits of writing fast, reliable unit tests. Instead of spending time on trying to figure out how to set fields so validation rules will pass, what to set up to pass the trigger without error etc. Mocking allows you to get result from the query without all operations on the database. 

Here we can not only save hours of figuring out test data creation, but also minutes during tests execution. So if someone says that SOQL Lib take CPU time and that bothers those people. I believe they cannot allow themselfs to 

## It's Just a Query Builder

No, it's much more than that.

The query builder is just one component of SOQL Lib. SOQL Lib itself is a lightweight yet powerful alternative to FFLib Selectors. It provides all the benefits of FFLib and significantly more. The main advantage is that it's extremely easy to use compared to FFLib.

**You can:**
- Mock your queries
- Cache your query results
- Build your own lightweight selectors
- Control Field-Level Security (FLS)
- Control sharing rules
- Use result functions to make your code cleaner and faster
- Use the query builder to avoid string concatenation

**For a comprehensive list of benefits, check:**
- [SOQL Basic Features](/soql/basic-features)
- [SOQL Cache Basic Features](/cache/basic-features)

