---
sidebar_position: 13
---

# Mocking


```apex
public with sharing class ExampleController {

    public static List<Account> getPartnerAccounts(String accountName) {
        return AccountSelector.Query
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
@isTest
public class ExampleControllerTest {

    public static List<Account> getPartnerAccounts(String accountName) {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'MyAccount 1'),
            new Account(Name = 'MyAccount 2')
        };

        SOQL.setMock('ExampleController.getPartnerAccounts', accounts);

        // Test
        List<Account> result = ExampleController.getAccounts('MyAccount');

        Assert.areEqual(accounts, result);
    }
}
```
