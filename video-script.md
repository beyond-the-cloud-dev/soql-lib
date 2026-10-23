# SOQL Lib: YouTube video script

Draft, 2026-10-06. SOQL Lib v6.12.0. Built from the repo, the docs, the [2023 blog post](https://blog.beyondthecloud.dev/blog/soql-lib) and the November 2025 deck.

How to read it: `>` lines are spoken word for word, code blocks are on screen, bullets are talking points.

## Table of contents

1. [Brief](#brief)
2. [Run of show](#run-of-show)
3. [Feature coverage](#feature-coverage)
4. [Script](#script)
    1. [Hook](#hook)
    2. [The problems](#the-problems)
        1. [Inline queries everywhere](#1-inline-queries-everywhere)
        2. [Dynamic queries built from strings](#2-dynamic-queries-built-from-strings)
        3. [FLS and sharing are set in two different places](#3-fls-and-sharing-are-set-in-two-different-places)
        4. [Unit tests are really integration tests](#4-unit-tests-are-really-integration-tests)
        5. [Loops to transform results](#5-loops-to-transform-results)
        6. ["Too many SOQL queries: 101"](#6-too-many-soql-queries-101)
    3. [fflib and its selector layer](#fflib-and-its-selector-layer)
        1. [What a selector layer is](#what-a-selector-layer-is)
        2. [How fflib builds it](#how-fflib-builds-it)
        3. [What fflib gets right](#what-fflib-gets-right)
        4. [Where it hurts](#where-it-hurts)
    4. [Meet SOQL Lib](#meet-soql-lib)
        1. [Query builder instead of strings](#1-query-builder-instead-of-strings)
        2. [Automatic binding](#2-automatic-binding)
        3. [Dynamic conditions without if/else](#3-dynamic-conditions-without-ifelse)
        4. [Result methods instead of loops](#4-result-methods-instead-of-loops)
        5. [Small selectors](#5-small-selectors)
            1. [Default configuration](#51-default-configuration)
            2. [No duplicated queries](#52-no-duplicated-queries)
            3. [Minimal fields](#53-minimal-fields)
            4. [No method-naming overhead](#54-no-method-naming-overhead)
            5. [Change safety](#55-change-safety)
        6. [Secure by default](#6-secure-by-default)
        7. [FLS control per query](#7-fls-control-per-query)
        8. [Sharing control per query](#8-sharing-control-per-query)
        9. [Built-in mocking](#9-built-in-mocking)
        10. [Caching](#10-caching)
        11. [One class, optional modules](#11-one-class-optional-modules)
        12. [Use it your way](#12-use-it-your-way)
    5. [Critique](#critique)
        1. [Plain SOQL welcome](#1-plain-soql-welcome)
        2. [Easy to learn](#2-easy-to-learn)
        3. [Low overhead](#3-low-overhead)
        4. [More than a query builder](#4-more-than-a-query-builder)
    6. [Outro](#outro)
5. [Recording prep](#recording-prep)
    1. [Demo files](#demo-files)
6. [Sources](#sources)

## Brief

A 19-minute walkthrough of SOQL Lib for Apex developers. It covers six everyday SOQL problems and what fflib's selector layer does about them. Then it shows SOQL Lib's benefits live, one part each, covering every basic feature of the SOQL and Cache modules, and answers the usual critique.

| Item | Plan |
| --- | --- |
| Audience | Apex developers who write SOQL daily, many of them on fflib projects |
| Length | About 19:40; after the hook, the problems and fflib take 4:25, Meet SOQL Lib's benefit parts 12:20 and the critique 1:30 |
| Format | Slides rebuilt from the November 2025 deck for problems and concepts; VS Code and a scratch org for demos; face cam for hook and outro |
| Takeaway | Keep selectors small, build business queries inline, mock them in tests, cache what rarely changes |
| Version shown | v6.12.0 API. The 2023 post's `SOQL.setMock` is deprecated, so the script uses `SOQL.mock().thenReturn()` |
| Working title | Stop Writing SOQL Strings: Meet SOQL Lib |
| Call to action | Star the repo, try the Playground, comment with your worst selector |

Open questions:

- The fflib classes in `demo/` need fflib-apex-common, the `Application` factory and `PortalUser__c` to compile. Show them in the editor only, or deploy fflib to the demo org first?
- The deck says reads are "~70% of an org's activity". Is there a source to cite, or do we drop the number?

## Run of show

Six problems and fflib up front, then SOQL Lib's benefits, each shown live in its own part, then the critique.

| # | Segment | Time | On screen | Fixes |
| --- | --- | --- | --- | --- |
| 1 | Hook | 0:00–0:40 | A two-query method's 49-line test next to its SOQL Lib test with two mocks | |
| 2 | The problems | 0:40–3:20 | Six problem slides rebuilt from the deck, each with its "before" code | |
| 3 | fflib and its selector layer | 3:20–5:05 | Slide 9 diagram, redrawn; `PortalUserSelector`; the ApexMocks stub | |
| 4 | Meet SOQL Lib: intro | 5:05–5:35 | "Query better!" slide and the modules table | |
| 5 | Benefits 1–4: writing queries | 5:35–8:05 | Anonymous Apex and the `preview()` debug log | Problems 2 and 5 |
| 6 | Benefit 5: small selectors, with 5.1–5.5 | 8:05–11:15 | Both fflib classes from `demo/` rewritten live | Problem 1, fflib's boilerplate |
| 7 | Benefits 6–8: security | 11:15–12:50 | The mode table, `AccountVisibilityController`, the `SOQL_Account` constructor | Problem 3 |
| 8 | Benefit 9: mocking | 12:50–14:50 | Test class run and its timing | Problem 4, fflib's mock setup |
| 9 | Benefit 10: caching | 14:50–16:50 | `SOQL_CachedProfile` and `Limits.getQueries()` | Problem 6 |
| 10 | Benefits 11–12: adoption | 16:50–17:25 | Installation page, Build Your Selector page | |
| 11 | Critique | 17:25–18:55 | Critique page objections, Evaluator, Playground, an AI prompt, build-time numbers | |
| 12 | Outro | 18:55–19:40 | Face cam, then the GitHub repo | |

## Feature coverage

Every basic feature from both docs pages, and the benefit part that shows it.

[SOQL basic features](https://soql.beyondthecloud.dev/soql/basic-features):

| Feature | Covered in |
| --- | --- |
| Dynamic SOQL | Benefit 1 |
| Automatic Binding | Benefit 2 |
| Dynamic Conditions: `ignoreWhen`, a `FilterGroup` built at runtime | Benefit 3 |
| Enhanced Result Methods | Benefit 4 |
| Minimalistic Selectors | Benefit 5 |
| Default Configuration | Benefit 5.1 |
| Avoid Query Duplication | Benefit 5.2 |
| Minimal Fields | Benefit 5.3 |
| Field-Level Security Control: user mode, system mode | Benefits 6 and 7 |
| Sharing Control: with, without and inherited sharing | Benefit 8 |
| Mocking: list, single record, static resource, count, aggregate result | Benefit 9, steps 2 and 3 |

[Cache basic features](https://soql.beyondthecloud.dev/cache/basic-features):

| Feature | Covered in |
| --- | --- |
| Cache Storage Options: Apex transaction, Org Cache, Session Cache | Benefit 10, step 1 |
| Cached Selectors | Benefit 10, step 1 |
| Initial Query Bulk Population | Benefit 10, step 1 |
| Cache Result Methods | Benefit 10, step 2 |
| Performance Benefits | Benefit 10, step 2 |
| Auto-refresh After Hours | Benefit 10, step 3 |
| Cache Removal: trigger-based, programmatic | Benefit 10, step 3 |
| Cache Filtering Rules: unique field, overrides, condition requirement | Benefit 10, step 4 |
| Field-Level Security: system mode, `stripInaccessible()` | Benefit 10, step 4 |
| Mocking: cached results, initial query | Benefit 10, step 4 |

## Script

### Hook

**Time:** 0:00–0:40

**Demo:** `hook/`. The plain-SOQL twin carries the `Legacy` prefix, so both versions can live in one org.

Open on the code, not on a greeting. Left: a method with two queries and a real business rule, and the test for one of its paths. Right: the same method on SOQL Lib and the same test with two mocks.

> This method decides if a deal needs discount approval. Two queries: how many deals the account has won, and the deal's products. Key accounts can go thirty percent below list price, everyone else twenty.
>
> And this is the test for one path: an account, three won deals, a product, a price book entry, an opportunity and a line item. Forty-nine lines and six inserts before a single assert. In your org, add every validation rule, trigger and flow on those objects.
>
> With SOQL Lib, the same test is two mocks: thirteen lines, no inserts, no database.
>
> I'm Piotr from Beyond the Cloud. I built SOQL Lib, and in this video I'll show you how it fixes this and five other everyday SOQL problems.

The rule: a deal needs approval when any product is sold below its floor price, which is 30% under list price for key accounts (three or more won deals) and 20% under for everyone else. The loop is there for a reason: SOQL can't compare two fields (`UnitPrice` against `PricebookEntry.UnitPrice`) in `WHERE`. And the Discount field alone isn't enough, because reps often type the sales price directly.

Left, top: `LegacyDiscountApprovalService`, plain SOQL.

```apex
public with sharing class LegacyDiscountApprovalService {
    private static final Integer KEY_ACCOUNT_MIN_WON_DEALS = 3;
    private static final Decimal KEY_ACCOUNT_MAX_DISCOUNT = 0.30;
    private static final Decimal STANDARD_MAX_DISCOUNT = 0.20;

    public static Boolean needsApproval(Opportunity opportunity) {
        Integer wonDeals = [
            SELECT COUNT()
            FROM Opportunity
            WHERE AccountId = :opportunity.AccountId AND IsWon = true
        ];
        Decimal maxDiscount = wonDeals >= KEY_ACCOUNT_MIN_WON_DEALS ? KEY_ACCOUNT_MAX_DISCOUNT : STANDARD_MAX_DISCOUNT;

        for (OpportunityLineItem lineItem : [
            SELECT UnitPrice, PricebookEntry.UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunity.Id
        ]) {
            Decimal floorPrice = lineItem.PricebookEntry.UnitPrice * (1 - maxDiscount);
            if (lineItem.UnitPrice < floorPrice) {
                return true;
            }
        }
        return false;
    }
}
```

Left, bottom: the test for the key-account path in `LegacyDiscountApprovalServiceTest`, 49 lines and six inserts.

```apex
@IsTest
static void keyAccountCanGiveThirtyPercentDiscount() {
    Account account = new Account(Name = 'Acme');
    insert account;

    List<Opportunity> wonDeals = new List<Opportunity>();
    for (Integer i = 0; i < 3; i++) {
        wonDeals.add(new Opportunity(
            Name = 'Won deal ' + i,
            AccountId = account.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today()
        ));
    }
    insert wonDeals;

    Product2 product = new Product2(Name = 'Server', IsActive = true);
    insert product;

    PricebookEntry pricebookEntry = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = product.Id,
        UnitPrice = 100,
        IsActive = true
    );
    insert pricebookEntry;

    Opportunity opportunity = new Opportunity(
        Name = 'Acme servers',
        AccountId = account.Id,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(30),
        Pricebook2Id = Test.getStandardPricebookId()
    );
    insert opportunity;

    insert new OpportunityLineItem(
        OpportunityId = opportunity.Id,
        PricebookEntryId = pricebookEntry.Id,
        Quantity = 1,
        UnitPrice = 75
    );

    Test.startTest();
    Boolean needsApproval = LegacyDiscountApprovalService.needsApproval(opportunity);
    Test.stopTest();

    Assert.isFalse(needsApproval);
}
```

Right, top: `DiscountApprovalService` on SOQL Lib. It has no test-only code: each query is mocked by its SObject type.

```apex
public with sharing class DiscountApprovalService {
    private static final Integer KEY_ACCOUNT_MIN_WON_DEALS = 3;
    private static final Decimal KEY_ACCOUNT_MAX_DISCOUNT = 0.30;
    private static final Decimal STANDARD_MAX_DISCOUNT = 0.20;

    public static Boolean needsApproval(Opportunity opportunity) {
        Integer wonDeals = SOQL.of(Opportunity.SObjectType)
            .count()
            .whereAre(SOQL.Filter.with(Opportunity.AccountId).equal(opportunity.AccountId))
            .whereAre(SOQL.Filter.with(Opportunity.IsWon).isTrue())
            .toInteger();
        Decimal maxDiscount = wonDeals >= KEY_ACCOUNT_MIN_WON_DEALS ? KEY_ACCOUNT_MAX_DISCOUNT : STANDARD_MAX_DISCOUNT;

        List<OpportunityLineItem> lineItems = SOQL.of(OpportunityLineItem.SObjectType)
            .with(OpportunityLineItem.UnitPrice)
            .with('PricebookEntry', PricebookEntry.UnitPrice)
            .whereAre(SOQL.Filter.with(OpportunityLineItem.OpportunityId).equal(opportunity.Id))
            .toList();

        for (OpportunityLineItem lineItem : lineItems) {
            Decimal floorPrice = lineItem.PricebookEntry.UnitPrice * (1 - maxDiscount);
            if (lineItem.UnitPrice < floorPrice) {
                return true;
            }
        }
        return false;
    }
}
```

Right, bottom: the same test in `DiscountApprovalServiceTest`, 13 lines, two mocks and no inserts. The other path is the same test with `thenReturn(0)`.

```apex
@IsTest
static void keyAccountCanGiveThirtyPercentDiscount() {
    SOQL.mock(Opportunity.SObjectType).thenReturn(3);
    SOQL.mock(OpportunityLineItem.SObjectType).thenReturn(new List<OpportunityLineItem>{
        new OpportunityLineItem(UnitPrice = 75, PricebookEntry = new PricebookEntry(UnitPrice = 100))
    });

    Test.startTest();
    Boolean needsApproval = DiscountApprovalService.needsApproval(new Opportunity());
    Test.stopTest();

    Assert.isFalse(needsApproval);
}
```

### The problems

**Time:** 0:40–3:20

Six problems, 20–40 seconds each. Each gets its fix in a benefit part, so viewers stay for the answers.

| # | Problem | Time | Fixed in |
| --- | --- | --- | --- |
| 1 | Inline queries everywhere | 0:40–1:05 | Benefits 4, 5.1–5.3 and 9 |
| 2 | Dynamic queries built from strings | 1:05–1:30 | Benefits 1–3 |
| 3 | FLS and sharing are set in two different places | 1:30–2:10 | Benefits 6–8 |
| 4 | Unit tests are really integration tests | 2:10–2:40 | Benefit 9 |
| 5 | Loops to transform results | 2:40–3:00 | Benefit 4 |
| 6 | "Too many SOQL queries: 101" | 3:00–3:20 | Benefit 10 |

#### 1. Inline queries everywhere

**Demo:** `problems/1-inline-queries/`. `AccountHierarchyService` also builds its Map by hand, for the "no transformation" point.

SOQL is written inline wherever someone needs data: controllers, trigger handlers, batches, services. The same condition, such as "child accounts of this account", ends up in many classes.

```apex
// ChildAccountsController.cls
return [SELECT Id, Name FROM Account WHERE ParentId = :accountId];

// AccountHierarchyService.cls
for (Account childAccount : [SELECT Id, Name, Industry, ParentId FROM Account WHERE ParentId IN :parentIds]) {

// AccountHierarchySyncBatch.cls
return Database.getQueryLocator([SELECT Id, Name, Type FROM Account WHERE ParentId = :parentId]);
```

- **They can't be mocked.** A static `[SELECT ...]` always hits the database, so every test needs real records (problem 5).
- **They can't be extended.** You can't take an existing query and add a field or a condition; you copy it and edit the copy.
- **A changed condition means changing every copy.** If the rule for child accounts changes, every class with its own `WHERE ParentId = ...` has to be found and updated.
- **No control over the whole object.** There's no single place for a master condition that every query on an object must follow, such as "only active users", so each query has to remember it.
- **No transformation.** A query gives you a list. Need a Map, a Set or records grouped by a field? You iterate over the list and build that structure yourself, every time.

> Inline queries can't be mocked, can't be extended, can't share a rule, and only ever give you a list. Change one condition, and you're hunting for copies across the codebase.

#### 2. Dynamic queries built from strings

**Demo:** `problems/2-dynamic-queries/LegacyAccountSearchController.cls`.

Some queries must be built at runtime: optional filters, fields picked by the user, batch queries assembled from settings. So they're built from strings.

On screen: a codebase search for `'SELECT` (the deck's slide 5, re-shot on a public repo), then:

```apex
String query = 'SELECT Id, Name FROM Account WHERE BillingCity = \'Boston\'';
if (String.isNotEmpty(accountName)) {
    query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(accountName) + '%\'';
}
List<Account> accounts = Database.query(query);
```

- One forgotten `escapeSingleQuotes` opens SOQL injection.
- A missing space or quote breaks the query at runtime, not at compile time.
- Field names are plain text, so a typo compiles and fails in production.

Use this version, not slide 11's: the slide appends `FROM Account` after `WHERE` and never closes the `LIKE` quote.

**Live demo (about 20 extra seconds):** open `LegacyAccountSearchController`, a typical LWC search controller, and point at:

- five optional filters, each an `if` with quotes and `escapeSingleQuotes`;
- the `Type IN (...)` list, quoted value by value in a loop;
- one `WHERE` string shared by the search and the count query;
- `sortField` and `sortDirection` pasted into `ORDER BY` straight from the UI, where `escapeSingleQuotes` can't help.
- Bonus: PMD flags both `Database.query` calls in this class with `ApexSOQLInjection`.

> String SOQL is hard to read, and one missing escape away from injection.

#### 3. FLS and sharing are set in two different places

**Demo:** `problems/3-fls-and-sharing/LegacyAccountVisibilityController.cls`.

Plain Apex controls security with two switches in two places, as the docs' [Field-Level Security](https://soql.beyondthecloud.dev/soql/advanced/fls) and [Sharing](https://soql.beyondthecloud.dev/soql/advanced/sharing) pages explain. Field-level security and object permissions are set per query; sharing is set per class.

| What | Where you set it in plain Apex | Options |
| --- | --- | --- |
| FLS and object permissions | Each query | `WITH USER_MODE`, `WITH SYSTEM_MODE`, `Security.stripInaccessible()` |
| Sharing | The class declaration | `with sharing`, `without sharing`, `inherited sharing` |

The two switches also interact. In Salesforce's words, quoted on both docs pages: "User mode always applies sharing rules, but in system mode they're controlled by sharing keywords on the class."

```apex
public with sharing class LegacyAccountVisibilityController {
    public List<Account> getAccounts() {
        return [SELECT Id, Name, AnnualRevenue FROM Account WITH USER_MODE];
    }

    public List<Account> getAccountsWithoutSharing() {
        return new WithoutSharing().getAccounts();
    }

    public List<Account> getReadableAccountsWithoutSharing() {
        return Security.stripInaccessible(AccessType.READABLE, new WithoutSharing().getAccounts()).getRecords();
    }

    public without sharing class WithoutSharing {
        public List<Account> getAccounts() {
            return [SELECT Id, Name, AnnualRevenue FROM Account WITH SYSTEM_MODE];
        }
    }
}
```

- FLS is decided on the query and sharing on the class, so you need both to know what a query returns.
- One method with sharing and one without? An inner `without sharing` class exists only to switch the mode.
- FLS without sharing takes that inner class plus `Security.stripInaccessible()`.
- With `inherited sharing`, the same query behaves differently depending on the caller.

> In plain Apex, field-level security is set on the query and sharing on the class. Need both behaviors in one place? You end up with nested classes and stripInaccessible calls.

#### 4. Unit tests are really integration tests

**Demo:** `problems/4-integration-tests/` (`TestDataFactory` and `DiscountApprovalIntegrationTest`).

To test one query, you insert everything it touches, so a unit test turns into an integration test. This is the deck's slide 4 with neutral names, and the factory is real: every `create` method inserts a record.

```apex
@IsTest
static void calculatesOpportunityDiscount() {
    Account account = TestDataFactory.createAccount();
    Contract contract = TestDataFactory.createContract(account.Id);
    Contact contact = TestDataFactory.createContact(account.Id);
    Product2 product = TestDataFactory.createProduct();
    PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product.Id);
    Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
    OpportunityLineItem lineItem = TestDataFactory.createLineItem(opportunity.Id, pricebookEntry.Id);

    Test.startTest();
    Boolean needsApproval = LegacyDiscountApprovalService.needsApproval(opportunity);
    Test.stopTest();

    Assert.isTrue(needsApproval);
}
```

- Every required field must be filled.
- Validation rules you didn't know about still have to pass.
- Triggers add their own checks, and record-triggered flows run too.
- A callout somewhere in the chain needs a mock.
- The cost: slow test runs, and hours of setup for every new test.

> To test one query, you insert seven records, pass every validation rule, survive every trigger and flow, and mock a callout. That's not a unit test anymore.

#### 5. Loops to transform results

**Demo:** `problems/5-result-loops/LegacyAccountReportService.cls`.

Almost every query result gets reshaped by hand: a Set of names, a Map of Ids, records grouped by a field (the deck's slide 7).

```apex
Set<String> accountNames = new Set<String>();
for (Account account : [SELECT Name FROM Account]) {
    accountNames.add(account.Name);
}

Map<Id, Id> accountIdByContactId = new Map<Id, Id>();
for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
    accountIdByContactId.put(contact.Id, contact.AccountId);
}
```

- The same five lines of boilerplate repeat across the codebase.
- A loop isn't always the fastest way to build the result.

> Loops, loops everywhere. Five lines of boilerplate every time you need a Set or a Map.

#### 6. "Too many SOQL queries: 101"

**Demo:** `problems/6-too-many-soql-queries/LegacyReferenceDataService.cls`. For the error on camera, run `for (Integer i = 0; i < 101; i++) { LegacyReferenceDataService.isSandbox(); }` in Anonymous Apex.

Reference data is queried again in every transaction: Profile, User, Organization, BusinessHours, EmailTemplate, OrgWideEmailAddress (the deck's slide 8). Nothing caches it.

```apex
Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];

Profile adminProfile = [
    SELECT Id, Name
    FROM Profile
    WHERE Name = 'System Administrator'
    LIMIT 1
];
```

- Each repeat counts toward the 100-query limit, often from helpers called many times per transaction.
- The data changes rarely, yet every read goes to the database.

> Profile, Organization, BusinessHours: data that almost never changes, queried again in every transaction.

### fflib and its selector layer

**Time:** 3:20–5:05 · **Answered in:** benefits 5, 8 and 9

Most teams answer problems 1–6 with a selector layer, and on Salesforce that usually means fflib. Give it a fair hearing: many viewers use it every day.

> Most teams answer these problems the same way: a selector layer. And on Salesforce, a selector layer usually means fflib.

#### What a selector layer is

**~25 s.** A selector layer is one class per object that owns every query for that object. Domain, service, controller and batch code ask it for data instead of writing SOQL.

On screen: the deck's slide 9 diagram, redrawn. Domain, Service, Controller and Batch classes all call one Selector class (`selectById`, `selectByXXX`, `queryLocatorById`).

- One place for the object's fields and queries, so copies can't drift apart (problem 1).
- Security decided once, not by every developer on every query (problem 3).
- Generic queries such as `selectById` written once and reused.
- Tests can swap the selector for a mock (problem 4).

> A selector layer is a simple idea: one class per object owns every query for that object.

#### How fflib builds it

**Demo:** `fflib/` has `IPortalUserSelector`, `PortalUserSelector`, `Application` (the factory registration) and `OpportunitiesSelector`. They need fflib-apex-common, so show them in the editor only.

**~30 s.** fflib, the Apex Enterprise Patterns library (`fflib-apex-common`), started at FinancialForce more than ten years ago. It splits an app into Service, Domain, Selector and Unit of Work layers; its selector base class is `fflib_SObjectSelector`.

The `PortalUserSelector` in `demo/` is fflib.dev's own example. Creating one takes four steps:

1. An interface for the selector (`IPortalUserSelector`).
2. The class: a field list, `getSObjectType()`, factory boilerplate, then one method per query.
3. A registration in the Application factory: a map in `Application.cls`, or a custom metadata binding in fflib.dev's example.
4. Callers get the selector through the factory: `Application.Selector.newInstance(PortalUser__c.SObjectType)`.

Queries go through `fflib_QueryFactory`, with conditions as strings that bind to local variables:

```apex
public List<Account> selectByIndustry(String industry) {
    return (List<Account>) Database.query(
        newQueryFactory().setCondition('Industry = :industry').toSOQL()
    );
}
```

#### What fflib gets right

**~15 s.** Be fair here; fflib users will check.

- Queries and default fields live in one class per object.
- Object and field access checks are built in; newer versions can run a selector in user mode (`fflib_SObjectSelector.DataAccess.USER_MODE`).
- The Application factory lets tests swap a selector for an ApexMocks stub.
- It's a known standard, with a Trailhead module and Andrew Fawcett's enterprise architecture book behind it.

> fflib solved real problems, and it's still the default answer in many orgs.

#### Where it hurts

**Demo:** the ApexMocks stub is in `fflib/OpportunitiesSelectorMockTest.cls`.

**~35 s.** On screen: `PortalUserSelector.cls` (58 lines), `OpportunitiesSelector.selectByIdWithProducts`, then the mock below. Call `selectByIdWithProducts` the classic version: the `String.format` code in `demo/` is the older fflib sample, and today's sample app builds it with `fflib_QueryFactory`, which still needs four extra selectors. Naming it heads off strawman comments.

- Four steps and 58 lines before the first query, in fflib.dev's own example.
- One method per business query. Most queries are one-off, yet they all land in the selector, which grows into a god class and a merge-conflict magnet.
- Near-identical methods that differ by a field, a limit or an order, with names like `selectByFieldAAndFieldBWithDescOrder()`.
- Conditions are strings bound to local variable names, so a typo fails at runtime, not at compile time.
- No sharing per query: fflib.dev says to handle sharing at the controller layer, which brings back problem 3.
- Mocking needs the interface, the factory and ApexMocks. This is from fflib's sample app:

```apex
fflib_ApexMocks mocks = new fflib_ApexMocks();
IOpportunitiesSelector selectorMock = (IOpportunitiesSelector) mocks.mock(IOpportunitiesSelector.class);

mocks.startStubbing();
mocks.when(selectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
mocks.when(selectorMock.selectByIdWithProducts(testOppsSet)).thenReturn(testOppsList);
mocks.stopStubbing();

Application.Selector.setMock(selectorMock);
```

- Together, that makes the learning curve steep for junior developers.

> fflib solved real problems more than ten years ago. But most queries in a project are one-off, and forcing each of them into a shared selector creates new problems.
>
> So what if you kept the good parts of a selector layer, and fixed all of this with one small library?

### Meet SOQL Lib

**Time:** 5:05–17:25

SOQL Lib is an MIT-licensed Apex library for building, securing, testing and caching queries: one core class with a fluent API, plus two optional modules. After a 30-second intro, each benefit gets its own part, shown live.

**Intro (5:05–5:35).** On screen: the deck's "Query better!" slide, then the modules table.

| Module | Class | What it adds |
| --- | --- | --- |
| SOQL (core) | `SOQL.cls` | Query builder, selectors, FLS and sharing control, mocking, result methods |
| Cache (optional) | `SOQLCache.cls` | Cached results in the Apex transaction, Org Cache or Session Cache |
| Evaluator (optional) | `SOQLEvaluator.cls` | Result methods and mocking for plain `[SELECT ...]` queries |

> SOQL Lib's promise is simple: query better. Here's everything you get, and I'll show you all of it.

#### 1. Query builder instead of strings

**Time:** 5:35–6:15 · **Fixes:** problem 2 · **Feature:** Dynamic SOQL

**Demo:** `soql-lib/01-query-builder/QueryBuilderExamples.cls`.

Build any query with a fluent API, right where you need it. Benefits 1–4 run in Anonymous Apex.

```apex
// SELECT Id, Name, Industry FROM Account (runs in USER_MODE)
List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name, Account.Industry)
    .toList();
```

Then rewrite problem 2's string query: no quotes or spaces to get right, and every field is a token the compiler checks.

```apex
String accountName = 'Acme';

List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Boston'))
    .whereAre(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    .toList();
```

Mention that both queries already run in user mode, even though the text doesn't say so; benefit 6 explains it.

> Same query, no strings. The compiler checks every field.

#### 2. Automatic binding

**Time:** 6:15–6:45 · **Fixes:** problem 2 · **Feature:** Automatic Binding

**Demo:** `soql-lib/02-automatic-binding/AutomaticBindingExamples.cls`.

Every value is bound and run through `Database.queryWithBinds`, so values can't inject SOQL.

Add `.preview()` to benefit 1's query and run it. The debug log shows the query with `:v1` and `:v2` binds, and the binding map below it.

```apex
String accountName = 'Acme';

List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(SOQL.Filter.with(Account.BillingCity).equal('Boston'))
    .whereAre(SOQL.Filter.name().contains(accountName).ignoreWhen(String.isEmpty(accountName)))
    .preview()
    .toList();
```

> Every value is a bind variable. There's nothing to escape, and nothing to inject.

#### 3. Dynamic conditions without if/else

**Time:** 6:45–7:25 · **Fixes:** problem 2 · **Feature:** Dynamic Conditions

**Demo:** `soql-lib/03-dynamic-conditions/AccountSearchController.cls`, the SOQL Lib rewrite of `LegacyAccountSearchController`. Each filter is one line with `ignoreWhen`, the search and the count share one `FilterGroup`, and the sort field from the UI is mapped to an `SObjectField` token (unknown values fall back to Name). Binding protects values, not field names, so sort fields still need that map. PMD finds no injection or CRUD issues in this version.

`ignoreWhen()` drops a filter at runtime, and filter groups can be built in code.

**Step 1.** Set `accountName` to `''` and run benefit 2's query again: `ignoreWhen` drops the name filter, with no `if`.

**Step 2.** Build a `FilterGroup` in code, add to it in an `if`, then pass it in. `anyConditionMatching()` switches the group from AND to OR.

```apex
Boolean onlyCustomers = true;

SOQL.FilterGroup filters = SOQL.FilterGroup
    .add(SOQL.Filter.with(Account.BillingCity).equal('Boston'));

if (onlyCustomers) {
    filters.add(SOQL.Filter.with(Account.Type).equal('Customer'));
}

List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .whereAre(filters)
    .toList();
```

> Conditions come and go at runtime, and the query never turns into string surgery.

#### 4. Result methods instead of loops

**Time:** 7:25–8:05 · **Fixes:** problem 5 · **Feature:** Enhanced Result Methods

**Demo:** `soql-lib/04-result-methods/AccountReportService.cls`, the twin of `LegacyAccountReportService`.

`toValuesOf`, `toIdsOf`, `toMap`, `toAggregatedMap`, `doExist` and more replace hand-written loops; per the docs, `toValuesOf` runs about twice as fast as the loop.

Bring back problem 5's loops, then replace each with one line.

```apex
Set<String> accountNames = SOQL.of(Account.SObjectType).toValuesOf(Account.Name);
Map<String, String> accountIdByContactId = SOQL.of(Contact.SObjectType).toMap(Contact.Id, Contact.AccountId);
Set<Id> ownerIds = SOQL.of(Account.SObjectType).toIdsOf(Account.OwnerId);
Id adminProfileId = SOQL.of(Profile.SObjectType)
    .whereAre(SOQL.Filter.with(Profile.Name).equal('System Administrator'))
    .toId();
Boolean hasPartners = SOQL.of(Account.SObjectType).byRecordType('Partner').doExist();
Map<String, List<SObject>> accountsByIndustry = SOQL.of(Account.SObjectType)
    .with(Account.Name, Account.Industry)
    .toAggregatedMap(Account.Industry);
```

Then flash the full list from the deck's slide 15: `toId`, `toIds`, `toIdsOf`, `toValueOf`, `toValuesOf`, `toInteger`, `toObject`, `toList`, `toAggregated`, `toAggregatedProxy`, `toMap`, `toAggregatedMap`, `toQueryLocator`.

> Each of these lines replaces a loop you've written a hundred times.
>
> Inline queries are great, but some setup repeats in every query: default fields, the security mode. That's what a selector is for.

#### 5. Small selectors

**Time:** 8:05–8:45, then 5.1–5.5 until 11:15 · **Fixes:** problem 1, fflib's boilerplate · **Feature:** Minimalistic Selectors

**Demo:** `soql-lib/05-small-selectors/SOQL_PortalUser.cls`. The `PortalUser__c` object is in `demo/main/default/objects/`, so the selector deploys.

One selector per object holds only defaults and generic methods; business queries stay inline. Benefit 5 and its five sub-parts below rewrite both fflib classes from `demo/` live; this is the part fflib users will share.

`PortalUserSelector` (58 lines, four setup steps) becomes `SOQL_PortalUser` (10 lines): no interface, no factory registration.

```apex
public inherited sharing class SOQL_PortalUser extends SOQL implements SOQL.Selector {
    public static SOQL_PortalUser query() {
        return new SOQL_PortalUser();
    }

    private SOQL_PortalUser() {
        super(PortalUser__c.SObjectType);
        with(PortalUser__c.Id, PortalUser__c.SSOId__c, PortalUser__c.FirstName__c, PortalUser__c.LastName__c, PortalUser__c.DisplayName__c);
    }
}
```

> Fifty-eight lines and four setup steps become ten lines.

##### 5.1 Default configuration

**Time:** 8:45–9:15 · **Fixes:** problem 1 · **Feature:** Default Configuration

**Demo:** `soql-lib/05.1-default-configuration/SOQL_User.cls`.

Default fields, FLS mode, sharing mode and mock ID are set once, in the selector's constructor. Show the `SOQL_Account` constructor from `examples/`:

```apex
private SOQL_Account() {
    super(Account.SObjectType);
    // default settings
    with(Account.Id, Account.Name);
    systemMode();
    withoutSharing();
    mockId(MOCK_ID);
}
```

A master condition goes in the constructor too, and every query through the selector gets it. This fixes problem 1's last point:

```apex
private SOQL_User() {
    super(User.SObjectType);
    with(User.Id, User.Name, User.Email);
    // master condition: no query through this selector returns inactive users
    whereAre(Filter.with(User.IsActive).isTrue());
}
```

> Decide the defaults once. Every query through this selector gets them.

##### 5.2 No duplicated queries

**Time:** 9:15–9:55 · **Fixes:** problem 1 · **Feature:** Avoid Query Duplication

**Demo:** `soql-lib/05.2-no-duplicated-queries/` (`PortalUserService`, and `ChildAccountsService` with `byParentId()`).

`byId`, `byIds` and `byRecordType` come built in; other generic queries are written once, in the selector.

**Step 1.** The three fflib methods become one-liners:

```apex
List<PortalUser__c> users = SOQL_PortalUser.query().byIds(userIds).toList();
PortalUser__c portalUser = (PortalUser__c) SOQL_PortalUser.query().byId(userId).toObject();
List<PortalUser__c> allUsers = SOQL_PortalUser.query().toList();
```

**Step 2.** Add the generic queries many classes need. Each method returns the selector, so it chains.

```apex
public SOQL_PortalUser bySsoId(String ssoId) {
    whereAre(Filter.with(PortalUser__c.SSOId__c).equal(ssoId));
    return this;
}

public String toDisplayName(Id userId) {
    return (String) byId(userId).toValueOf(PortalUser__c.DisplayName__c);
}

// usage
PortalUser__c ssoUser = (PortalUser__c) SOQL_PortalUser.query().bySsoId(ssoId).toObject();
String displayName = SOQL_PortalUser.query().toDisplayName(userId);
```

Problem 1's `WHERE ParentId = ...` copies become one `byParentId()` method, already in `SOQL_Account` in `examples/`. Change the rule there, and every caller follows.

> Write a generic query once, in the selector, and nobody copies it again.

##### 5.3 Minimal fields

**Time:** 9:55–10:25 · **Feature:** Minimal Fields

**Demo:** `soql-lib/05.3-minimal-fields/ContactDetailsController.cls`.

A selector keeps a small default field set; each caller adds only the fields it needs, parent fields included. That's the extension problem 1's static queries can't do. This uses `SOQL_Contact` from `examples/`.

```apex
List<Contact> contacts = SOQL_Contact.query()
    .byAccountId(accountId)
    .with(Contact.Email, Contact.Phone, Contact.Department, Contact.Title)
    .with('Account', Account.Name, Account.Industry)
    .toList();
```

Call selector methods first: `with()` and the other builder methods return the generic `SOQL.Queryable`.

> Pull only what you need, when you need it.

##### 5.4 No method-naming overhead

**Time:** 10:25–10:55 · **Fixes:** fflib's method sprawl

**Demo:** `soql-lib/05.4-no-method-naming-overhead/OpportunityProductsController.cls`.

Inline queries mean no `selectByFieldAAndFieldBWithDescOrder()`. `selectByIdWithProducts` becomes an inline query in the controller that needs it; start from `SOQL_Opportunity` in `examples/`.

```apex
List<Opportunity> opportunities = SOQL_Opportunity.query()
    .with(Opportunity.Name, Opportunity.Amount, Opportunity.StageName, Opportunity.CloseDate)
    .with(SOQL.SubQuery.of('OpportunityLineItems')
        .with(OpportunityLineItem.Quantity, OpportunityLineItem.UnitPrice, OpportunityLineItem.TotalPrice)
        .with('PricebookEntry.Product2', Product2.Name, Product2.ProductCode)
        .with('PricebookEntry.Pricebook2', Pricebook2.Name)
    )
    .byIds(opportunityIds)
    .toList();
```

> No method to name. The query says what it does.

##### 5.5 Change safety

**Time:** 10:55–11:15 · **Fixes:** fflib's god classes

**Demo:** `soql-lib/05.5-change-safety/`: `AccountDashboardController` and `AccountExportController` build their own queries from `SOQL_Account`, so changing one can't break the other.

An inline query belongs to one feature, so changing it doesn't affect other code, and nobody fights over a shared selector in merge conflicts.

Lower third: "Selector = default fields, security, generic filters. Business query = inline."

> fflib mocks a selector through the Application factory and ApexMocks. SOQL Lib mocks the query itself. You'll see that in a few minutes.

#### 6. Secure by default

**Time:** 11:15–11:45 · **Fixes:** problem 3 · **Feature:** Field-Level Security Control

**Demo:** `soql-lib/06-secure-by-default/SecureByDefaultTest.cls`, the `System.runAs` proof.

Every query runs in user mode: object permissions, FLS and sharing are enforced unless you opt out. The mode is set on the query itself, next to the code that reads it.

| Methods | Mode | FLS | Sharing |
| --- | --- | --- | --- |
| none (default) | `USER_MODE` | enforced | with sharing |
| `.systemMode()` | `SYSTEM_MODE` | ignored | inherited from the calling class |
| `.systemMode().withSharing()` | `SYSTEM_MODE` | ignored | with sharing |
| `.systemMode().withoutSharing()` | `SYSTEM_MODE` | ignored | without sharing |
| `.systemMode().withoutSharing().stripInaccessible()` | `SYSTEM_MODE` | enforced, fields stripped | without sharing |

- Call back to `selectByIdWithProducts` from the fflib segment: user mode checks the parent, subquery and relationship fields in one go, which replaces its five `assertIsAccessible()` calls.
- Optional proof: in a test, `System.runAs` a user without Account access and run a default query. User mode throws; `.systemMode()` returns rows.

> Secure by default. You opt out on purpose, never by accident.

#### 7. FLS control per query

**Time:** 11:45–12:10 · **Fixes:** problem 3 · **Feature:** Field-Level Security Control

**Demo:** `soql-lib/07-fls-control/FlsControlExamples.cls`.

`.systemMode()` skips FLS when a query needs it; `.stripInaccessible()` removes fields the user can't read.

```apex
// System mode: FLS is skipped for this query only
List<Account> accounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .toList();

// System mode, but fields the user can't read are stripped
List<Account> readableAccounts = SOQL.of(Account.SObjectType)
    .with(Account.Id, Account.Name)
    .systemMode()
    .stripInaccessible()
    .toList();
```

> Need system mode for one query? Say so on that query, and only there.

#### 8. Sharing control per query

**Time:** 12:10–12:50 · **Fixes:** problem 3 · **Feature:** Sharing Control

**Demo:** `soql-lib/08-sharing-control/AccountVisibilityController.cls`, the twin of `LegacyAccountVisibilityController`.

`.withSharing()` and `.withoutSharing()` replace nested `without sharing` classes.

**Step 1.** Bring back problem 3's controller, then this: the same three behaviors in one class, no nesting and no `stripInaccessible` call. Each method maps to a row of the mode table in benefit 6.

```apex
public with sharing class AccountVisibilityController {
    public List<Account> getAccounts() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.AnnualRevenue)
            .toList();
    }

    public List<Account> getAccountsWithoutSharing() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.AnnualRevenue)
            .systemMode()
            .withoutSharing()
            .toList();
    }

    public List<Account> getReadableAccountsWithoutSharing() {
        return SOQL.of(Account.SObjectType)
            .with(Account.Id, Account.Name, Account.AnnualRevenue)
            .systemMode()
            .withoutSharing()
            .stripInaccessible()
            .toList();
    }
}
```

**Step 2.** Sharing defaults per selector: open the `SOQL_Account` constructor again.

- `systemMode()` and `withoutSharing()` are this selector's defaults, decided once. Even a with-sharing controller gets system mode without sharing through it: the selector decides.
- Selectors are declared `inherited sharing`: with `.systemMode()` alone, the query follows the caller's sharing keyword.

> Secure by default, flexible when you need it: per selector, and per query if you have to.

#### 9. Built-in mocking

**Time:** 12:50–14:50 · **Fixes:** problem 4, fflib's mock setup · **Feature:** Mocking

**Demo:** `soql-lib/09-mocking/`: `AccountController` with tests for a list, a single record, a static resource (`ProjectAccounts`) and a count; `LeadSourceReport` with a test for aggregate results.

`SOQL.mock(id).thenReturn(records)` gives unit tests without inserts, validation rules, triggers or flows, so they're faster to write and to run.

Open with problem 4's test: seven inserted records just to reach one query.

**Step 1: give the query an ID.** Name the class `AccountController`: `examples/` already has an `ExampleController`.

```apex
public with sharing class AccountController {
    public static List<Account> getPartnerAccounts(String accountName) {
        return SOQL_Account.query()
            .with(Account.BillingCity, Account.BillingCountry)
            .whereAre(SOQL.Filter.name().contains(accountName))
            .whereAre(SOQL.Filter.recordType().equal('Partner'))
            .mockId('AccountController.getPartnerAccounts')
            .toList();
    }
}
```

**Step 2: mock it in one statement (list of records).** Run the test and keep its run time on screen. Then put fflib's ApexMocks stub next to it: seven lines plus an interface and a factory, against one statement.

```apex
@IsTest
static void getPartnerAccounts() {
    SOQL.mock('AccountController.getPartnerAccounts').thenReturn(new List<Account>{
        new Account(Name = 'Partner 1'),
        new Account(Name = 'Partner 2')
    });

    Test.startTest();
    List<Account> result = AccountController.getPartnerAccounts('Partner');
    Test.stopTest();

    Assert.areEqual(2, result.size());
}
```

**Step 3: the other shapes `thenReturn` accepts.** One line each; the full tests are in `AccountControllerTest` and `LeadSourceReportTest`.

```apex
// single record
SOQL.mock('AccountController.getPartnerAccount').thenReturn(new Account(Name = 'Acme'));

// records from a static resource CSV
SOQL.mock('AccountController.getPartnerAccounts').thenReturn(Test.loadData(Account.SObjectType, 'ProjectAccounts'));

// count: the query ends with .count() ... .toInteger()
SOQL.mock('AccountController.countPartnerAccounts').thenReturn(2);

// aggregate result: the query ends with .toAggregatedProxy()
SOQL.mock('LeadSourceReport.countLeadsBySource').thenReturn(new List<Map<String, Object>>{
    new Map<String, Object>{ 'LeadSource' => 'Web', 'total' => 10 },
    new Map<String, Object>{ 'LeadSource' => 'Phone', 'total' => 5 }
});
```

**Step 4: shortcuts, and why the mocks stay honest.**

- No mock ID? `SOQL.mock(Account.SObjectType)` mocks every Account query that has no ID of its own.
- A selector can set the ID in its constructor (`mockId(MOCK_ID)` in `SOQL_Account`), so one mock covers every query through it, unless the query sets its own ID.
- Register mocks before the code under test builds its query; `throwException()` tests the error path.
- Mocks behave like SOQL: `Id` is always added, and unqueried fields are stripped when the query has no parent fields or functions.
- Mocked queries still count, so a query in a loop hits the 100-query limit. Several mocks with one ID are returned in order; the last one repeats.

> No inserts, no validation rules, no triggers. Just the records your test needs.

#### 10. Caching

**Time:** 14:50–16:50 · **Fixes:** problem 6 · **Features:** all ten Cache basic features

**Demo:** `soql-lib/10-caching/`: `SOQL_CachedOrganization` and `ReferenceDataService`, the cached twin of `LegacyReferenceDataService`.

SOQL Cache keeps reference data in the Apex transaction, Org Cache or Session Cache, so repeated lookups cost no queries.

**Step 1: a cached selector (Cache Storage Options, Cached Selectors, Initial Query Bulk Population).** Open `SOQL_CachedProfile` from `examples/`.

```apex
public without sharing class SOQL_CachedProfile extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedProfile query() {
        return new SOQL_CachedProfile();
    }

    private SOQL_CachedProfile() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        with(Profile.Id, Profile.Name, Profile.UserType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType);
    }

    public SOQL_CachedProfile byName(String name) {
        whereEqual(Profile.Name, name);
        return this;
    }
}
```

- Three storage options: `cacheInApexTransaction()` lasts one transaction, `cacheInOrgCache()` is shared across users, `cacheInSessionCache()` lasts one user session.
- `initialQuery()` runs once on an empty cache and loads every profile; after that, any `byName()` is served from cache.
- The deck's `OrganizationSelector.isSandbox()` is the same pattern: a cached selector on `Organization`, filtered by `Id`.

**Step 2: prove it (Cache Result Methods, Performance Benefits).** Print `Limits.getQueries()` before and after. The count rises once on a cold cache; run the script again and it stays at zero.

```apex
System.debug(Limits.getQueries());

Id adminProfileId = SOQL_CachedProfile.query().byName('System Administrator').toId();
Boolean hasStandardUser = SOQL_CachedProfile.query().byName('Standard User').doExist();
String userType = (String) SOQL_CachedProfile.query().byName('System Administrator').toValueOf(Profile.UserType);
Profile adminProfile = (Profile) SOQL_CachedProfile.query().byName('System Administrator').toObject();

System.debug(Limits.getQueries());
```

- Cache result methods: `toId()`, `toIdOf()` for a lookup's Id, `doExist()`, `toValueOf()`, `toObject()`.
- The docs put a cache read at about 10 ms, against 50–200 ms for a database query.
- Cache what rarely changes: Profile, BusinessHours, OrgWideEmailAddress, User, custom metadata. Not Account, Contact or Opportunity. Cache only the fields you need.

**Step 3: keep it fresh (Auto-refresh After Hours, Cache Removal).**

- Cached records refresh after 48 hours by default; `maxHoursWithoutRefresh(12)` changes the window.
- `SOQLCache.removeFromCache(Trigger.old)` in a trigger clears changed records; call it from code after an update too.

**Step 4: the rules (Cache Filtering Rules, Field-Level Security, Mocking).**

- A cached query needs a condition on a unique field such as `Id`, `Name` or `DeveloperName`. `allowFilteringByNonUniqueFields()` and `allowQueryWithoutConditions()` opt out.
- Cached queries run in system mode; `.stripInaccessible()` applies FLS to the cached records.
- `SOQLCache.mock('id').thenReturn(profile)` mocks the cached result; `SOQL.mock()` can mock the initial query instead.

> The fastest query is the one you never run.

#### 11. One class, optional modules

**Time:** 16:50–17:10

The core is `SOQL.cls`; Cache and Evaluator are optional. It's MIT-licensed and installs as an unlocked package (`btcdev` namespace), an unmanaged package, the Deploy to Salesforce button, or copied files.

On screen: the Installation page.

> One class to install. Add Cache or Evaluator only when you need them.

#### 12. Use it your way

**Time:** 17:10–17:25

Inline queries, selectors, or both: SOQL Lib doesn't force selectors on you, and the docs show six selector styles, including one that mirrors fflib.

On screen: the Build Your Selector page, styles A to F.

> Start inline, add selectors when you need them, or mirror fflib if your team prefers. It's your call.

### Critique

**Time:** 17:25–18:55

Answer the objections viewers will post anyway, using the docs' [Critique page](https://soql.beyondthecloud.dev/critique). Each point opens with the objection on screen, then the answer.

> Before you write that comment: here are the objections I hear most, and my answers.

#### 1. Plain SOQL welcome

**Time:** 17:35–17:50 · **Objection:** "I don't want to learn a new syntax."

**Demo:** `critique/1-plain-soql-welcome/` (`AccountEvaluatorService` and its test).

`SOQLEvaluator` adds result methods and mocking to `[SELECT ...]` queries, with no new syntax.

```apex
Set<Id> accountIds = SOQLEvaluator.of([SELECT Id FROM Account]).toIds();
Set<String> accountNames = SOQLEvaluator.of([SELECT Id, Name FROM Account]).toValuesOf(Account.Name);
```

> Like your SOQL the way it is? Keep it, and still get result methods and mocking.

#### 2. Easy to learn

**Time:** 17:50–18:20 · **Objection:** "SOQL Lib is more complex than plain SOQL."

The API stays as close to SOQL as Apex allows; only reserved words such as `select`, `where` and `limit` needed other names.

| On screen | Line to say |
| --- | --- |
| Scroll the interfaces at the top of `SOQL.cls` | "Everything you can call is listed here, so there's nothing to memorize." |
| The Playground: paste the hook's SOQL, get the SOQL Lib version | "Paste a SOQL query, get SOQL Lib code." |
| The AI prompt from the Critique page, run in your IDE | "Point your AI assistant at SOQL.cls and SOQL_Test.cls, and it writes the query for you." |

The prompt: "Based on SOQL.cls and SOQL_Test.cls, understand how SOQL Lib works. Write an inline query that returns all accounts with Employee Number greater than 100."

In practice it's often simpler than plain SOQL: one result method instead of a loop (benefit 4), a builder instead of string concatenation (benefit 1).

> It's SOQL with method names, and everything you need is one scroll away.

#### 3. Low overhead

**Time:** 18:20–18:40 · **Objection:** "Building queries at runtime costs CPU time."

**Demo:** `critique/3-low-overhead/QueryBuildBenchmark.cls`. Run `System.debug(QueryBuildBenchmark.averageBuildTimeMs(100));` to measure it live.

Per the docs, building a query takes about 1 ms for a simple query and under 2 ms for a complex one. Even 100 complex queries in one transaction use about 200 ms of the 10,000 ms CPU limit.

- Some result methods beat your own loop: `toValuesOf` runs about twice as fast, thanks to an aggregation trick.
- Mocked tests skip the inserts; per the docs, they run in milliseconds to seconds, not minutes.

On screen: those numbers from the Critique page.

> Building a query costs about a millisecond. That's not where your CPU time goes.

#### 4. More than a query builder

**Time:** 18:40–18:55 · **Objection:** "It's just a query builder."

The builder is one part. Recap what this video showed: small selectors (benefit 5), FLS and sharing control (benefits 6–8), mocking (benefit 9), caching (benefit 10), result methods (benefit 4) and no string concatenation (benefit 1).

> It's not just a query builder. It's your selector layer, your test mocks and your cache, in one small library.

### Outro

**Time:** 18:55–19:40

Face cam, word for word; cut to the GitHub repo on the star line.

> So that's SOQL Lib. Build business queries inline, keep your selectors small, mock your queries in tests, and cache what rarely changes.
>
> You don't have to migrate everything at once. Start with one selector or one test, or wrap an existing query with SOQLEvaluator.
>
> The docs, the GitHub repo, the Playground and a post on why you need a selector layer at all are linked below. If this saved you time, give the repo a star. It really helps.
>
> And tell me in the comments: what's the worst selector in your org? I might rewrite it in the next video. See you there.

## Recording prep

Deck (it is marked confidential, so rebuild before it goes public):

- [ ] Rebuild the slides in Beyond the Cloud branding.
- [ ] Re-shoot slide 5's codebase search on a public repo; the original shows a client org's class names.
- [ ] Replace slide 4's test with problem 4's neutral version; the original method name comes from a client org.
- [ ] Redraw slide 9's diagram; it is the classic fflib image.
- [ ] Fix slide 11's "before" query (`FROM` after `WHERE`, unclosed `LIKE` quote).
- [ ] Slide 12 marks `MOCK_ID` with `@IsTest`; `examples/` uses `@TestVisible`.
- [ ] Add slides the deck doesn't have yet: problems 1 and 3, fflib's four setup steps, and the ApexMocks stub.

Org and code:

- [ ] Deploy in this order: `force-app`, `examples`, then the `demo/` folders except `fflib/` (see Demo files).
- [ ] Decide how to show the fflib classes (open question in the Brief).
- [ ] Deploy demo folders one at a time, for example `sf project deploy start --source-dir demo/main/default/classes/dynamic-queries`. The fflib classes in `demo/` don't compile on their own, so deploying all of `demo/` fails.
- [ ] Give the demo org Platform Cache capacity for the `SOQL` partition, or record benefit 10 with `cacheInApexTransaction()`.
- [ ] Find a source for "~70% of org activity is reads", or cut it.

Docs, because viewers will click through:

- [ ] `soql/getting-started.md` and `docs/overview.md` show `WITH USER_MODE` in comments; `toString()` and `preview()` never print it.
- [ ] `soql/examples/debug.md` shows a "Query Preview" banner; the code prints "SOQL Preview" plus a "SOQL Binding" block.
- [ ] `soql/basic-features.md` and `critique.md` show the same broken "before" query; `critique.md` also has `Acccount` and `.put(acc)`.
- [ ] `soql/basic-features.md` says `contains()` generates `Name = :v1`; it generates `Name LIKE :v1`.
- [ ] `critique.md` assigns `SOQLEvaluator.of(...).toValuesOf()` to a `List<String>`; it returns `Set<String>`.

### Demo files

All paths are under `demo/main/default/classes/`. Plain-SOQL classes that have a SOQL Lib twin carry the `Legacy` prefix, so both can live in one org. `fflib/` is for the editor only; it needs fflib-apex-common to compile.

| Segment | Folder | What's there |
| --- | --- | --- |
| Hook | `hook/` | `LegacyDiscountApprovalService`, `DiscountApprovalService` and a test for each |
| Problem 1 | `problems/1-inline-queries/` | Three classes with their own copy of the child-accounts query |
| Problem 2 | `problems/2-dynamic-queries/` | `LegacyAccountSearchController` |
| Problem 3 | `problems/3-fls-and-sharing/` | `LegacyAccountVisibilityController` |
| Problem 4 | `problems/4-integration-tests/` | `TestDataFactory`, `DiscountApprovalIntegrationTest` |
| Problem 5 | `problems/5-result-loops/` | `LegacyAccountReportService` |
| Problem 6 | `problems/6-too-many-soql-queries/` | `LegacyReferenceDataService` |
| fflib | `fflib/` | `PortalUserSelector`, `IPortalUserSelector`, `Application`, `OpportunitiesSelector`, `IOpportunitiesSelector`, `OpportunitiesSelectorMockTest` |
| Benefits 1–4 | `soql-lib/01-…` to `soql-lib/04-…` | `QueryBuilderExamples`, `AutomaticBindingExamples`, `AccountSearchController`, `AccountReportService` |
| Benefits 5–5.5 | `soql-lib/05-…` to `soql-lib/05.5-…` | `SOQL_PortalUser`, `SOQL_User`, `PortalUserService`, `ChildAccountsService`, `ContactDetailsController`, `OpportunityProductsController`, `AccountDashboardController`, `AccountExportController` |
| Benefits 6–8 | `soql-lib/06-…` to `soql-lib/08-…` | `SecureByDefaultTest`, `FlsControlExamples`, `AccountVisibilityController` |
| Benefit 9 | `soql-lib/09-mocking/` | `AccountController`, `LeadSourceReport` and their tests |
| Benefit 10 | `soql-lib/10-caching/` | `SOQL_CachedOrganization`, `ReferenceDataService` |
| Critique 1 and 3 | `critique/…` | `AccountEvaluatorService` and its test, `QueryBuildBenchmark` |

Also in `demo/`: the `PortalUser__c` object (`objects/`) and the `ProjectAccounts` static resource (`staticresources/`) used by the static-resource mock test. Benefits 11 and 12 and critique points 2 and 4 show docs pages, so they have no code.

## Sources

These double as the video description links.

- [SOQL Lib](https://blog.beyondthecloud.dev/blog/soql-lib), Beyond the Cloud blog, July 10, 2023: motivation and the fflib critique. Its code predates v6.12.0.
- [Why do you need an Apex Selector Layer?](https://blog.beyondthecloud.dev/blog/why-do-you-need-selector-layer), Beyond the Cloud blog, January 16, 2025: selector layer benefits and the fflib assessment.
- [soql-lib on GitHub](https://github.com/beyond-the-cloud-dev/soql-lib): README, `examples/`, `demo/`.
- Docs: [Overview](https://soql.beyondthecloud.dev/docs/overview) · [Installation](https://soql.beyondthecloud.dev/installation) · [SOQL Basic Features](https://soql.beyondthecloud.dev/soql/basic-features) · [Build Your Selector](https://soql.beyondthecloud.dev/soql/build-selector)
- Docs: [Mocking](https://soql.beyondthecloud.dev/soql/advanced/mocking) · [Field-Level Security](https://soql.beyondthecloud.dev/soql/advanced/fls) · [Sharing](https://soql.beyondthecloud.dev/soql/advanced/sharing)
- Docs: [Cache](https://soql.beyondthecloud.dev/cache/getting-started) · [Cache Basic Features](https://soql.beyondthecloud.dev/cache/basic-features) · [Evaluator](https://soql.beyondthecloud.dev/evaluator/getting-started) · [Critique](https://soql.beyondthecloud.dev/critique) · [Playground](https://soql.beyondthecloud.dev/playground)
- fflib: [Selector layer overview](https://fflib.dev/docs/selector-layer/overview) and [basic example](https://fflib.dev/docs/selector-layer/example) (`PortalUserSelector`, four setup steps, sharing at the controller layer).
- fflib: [fflib-apex-common-samplecode](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode): `OpportunitiesSelector` and the ApexMocks stub in `OpportunitiesServiceTest`.
- SOQL Lib deck, November 2025 (internal, not for the description): problem framing and slide order.
