---
sidebar_position: 13
---

# Mocking

Mock SOQL results in Unit Tests.
## Mock Single Record

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {

    public static List<Account> getAccountByName(String accountName) {
        return AccountSelector.query()
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).contains(accountName))
            )
            .setLimit(1)
            .mockId('ExampleController.getAccountByName')
            .toObject();
    }
}
```

Pass single SObject record to SOQL class, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {
    private static final String TEST_ACCOUNT_NAME = 'MyAccount 1';

    @IsTest
    static void getAccountByName() {
        SOQL.setMock('ExampleController.getAccountByName', new Account(Name = TEST_ACCOUNT_NAME));

        Test.startTest();
        Account result = (Account) ExampleController.getAccountByName(TEST_ACCOUNT_NAME);
        Test.stopTest();

        Assert.areEqual(TEST_ACCOUNT_NAME, result.Name);
    }
}
```

During execution Selector will return record that was set by `.setMock` method.

## Mock Multiple Records

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query()
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .toList();
    }
}
```
Pass List of SObject records to SOQL class, and use mock ID to target query to be mocked.

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
        Test.stopTest();

        Assert.areEqual(accounts, result);
    }
}
```

During execution Selector will return List of records that was set by `.setMock` method.

## Mock Count Result

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccountsCount(String accountName) {
        return AccountSelector.query()
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .count()
            .mockId('ExampleController.getPartnerAccountsCount')
            .toInteger();
    }
}
```
Pass Integer value to SOQL class, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {
    private static final Integer TEST_VALUE = 5;

    @IsTest
    static void getPartnerAccountsCount() {
        SOQL.setMock('ExampleController.getPartnerAccountsCount', TEST_VALUE);

        Test.startTest();
        Integer result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.areEqual(TEST_VALUE, result);
    }
}
```

During execution Selector will return Integer count that was set by `.setMock` method.

## Mock with Static Resource

Set mocking ID in Query declaration.

```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.query()
            .with(Account.BillingCity)
            .with(Account.BillingCountry)
            .whereAre(SOQL.FilterGroup
                .add(SOQL.Filter.with(Account.Name).contains(accountName))
                .add(SOQL.Filter.recordType().equal('Partner'))
            )
            .mockId('ExampleController.getPartnerAccounts')
            .toList();
    }
}
```

Pass String value with name of Static Resource file with `.csv` records, and use mock ID to target query to be mocked.

```apex
@IsTest
public class ExampleControllerTest {

    @IsTest
    static void getPartnerAccounts() {
        SOQL.setMock('ExampleController.getPartnerAccounts', 'MyAccounts');

        Test.startTest();
        List<Account> result = ExampleController.getPartnerAccounts('MyAccount');
        Test.stopTest();

        Assert.isNotNull(result);
    }
}
```

During execution Selector will return records from Static Resource that was set by `.setMock` method.
