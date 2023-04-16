---
sidebar_position: 13
---

# Mocking

Mock SOQL results in Unit Tests.
## Mock Single Record

```apex
public with sharing class ExampleController {

    public static List<Account> getAccountByName(String accountName) {
        return AccountSelector.query
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
            )
            .setLimit(1)
            .mockId('ExampleController.getAccountByName')
            .asObject();
    }
}
```

```apex
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQL.setMock('ExampleController.getAccountByName', new Account(Name = TEST_ACCOUNT_NAME));

        Test.startTest();
        Account result = (Account) ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest;

        Assert.areEqual(TEST_ACCOUNT_NAME, result.Name);
    }
}
```
## Mock Multiple Records

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .asList();
    }
}
```

```apex
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.setMock('ExampleController.getPartnerAccounts', accounts);

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest;

        Assert.areEqual(accounts, result);
    }
}
```

## Mock Count Result

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccountsCount(String accountName) {
        return AccountSelector.query
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .count()
            .mockId('ExampleController.getPartnerAccountsCount')
            .asInteger();
    }
}
```

```apex
@IsTest
public class ExampleControllerTest {
    private static final Integer TEST_VALUE = 5;

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.setMock('ExampleController.getPartnerAccountsCount', TEST_VALUE);

        Test.startTest();
        Integer result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest;

        Assert.areEqual(TEST_VALUE, result);
    }
}
```

## Mock with Static Resource

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FiltersGroup
                .add(SOQL.Filter.with(Account.Name).likeAny(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .asList();
    }
}
```

```apex
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.setMock('ExampleController.getPartnerAccounts', 'MyAccounts');

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest;

        Assert.isNotNull(result);
    }
}
```
