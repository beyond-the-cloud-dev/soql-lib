# SOQL Lib

![Deploy to Scratch Org and run tests](https://github.com/beyond-the-cloud-dev/soql-lib/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib/branch/main/graph/badge.svg)](https://codecov.io/gh/beyond-the-cloud-dev/soql-lib)

The SOQL Lib provides functional constructs for SOQL queries in Apex.

For more details, please refer to the [documentation](https://soql-lib.vercel.app/).

You may also find [this blog post](https://beyondthecloud.dev/blog/soql-lib) about SOQL Lib interesting.

## Examples

```apex
// SELECT Id FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType).toList();
```

```apex
// SELECT Id, Name, Industry FROM Account
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(Account.Id, Account.Name, Account.Industry)
   .toList();
```

## Selector

Read [how to build your selector class](https://soql-lib.vercel.app/building-your-selector).

```apex
public inherited sharing class SOQL_Contact extends SOQL implements SOQL.Selector {
    public static final String MOCK_ID = 'SOQL_Contact';

    public static SOQL_Contact query() {
        return new SOQL_Contact();
    }

    private SOQL_Contact() {
        super(Contact.SObjectType);
        // default settings
        with(Contact.Id, Contact.Name, Contact.AccountId)
            .systemMode()
            .withoutSharing()
            .mockId(MOCK_ID);
    }

    public SOQL_Contact byAccountId(Id accountId) {
        whereAre(Filter.with(Contact.AccountId).equal(accountId));
        return this;
    }
}
```

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static List<Contact> getAccountContacts(Id accountId) {
        return SOQL_Contact.query()
            .byRecordType('Partner')
            .byAccountId(accountId)
            .with(Contact.Email)
            .toList();
    }
}
```

## Deploy to Salesforce

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=soql-lib&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Documentation

[SOQL Lib documentation](https://soql-lib.vercel.app/)

## Features

Read about the features in the [documentation](https://soql-lib.vercel.app/docs/basic-features).

1. **Dynamic SOQL**
2. **Automatic binding**
3. **Control FLS**
- 3.1 **User Mode**
- 3.2 **System Mode**
- 3.3 **stripInaccessible**
4. **Control Sharings Mode**
- 4.1 **with sharing**
- 4.2 **without sharing**
- 4.3 **inherited sharing**
5. **Mocking**
- 5.1 **Mock list of records**
- 5.2 **Mock single record**
- 5.3 **Mock with static resources**
- 5.4 **Mock count result**
6. **Avoid query duplicates**
7. **The default configuration for all queries**
8. **Dynamic conditions**
9. **Cache records**

----

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buycoffee.to/beyondthecloud)

----

## License notes

- For proper license management each repository should contain LICENSE file similar to this one.
- Each original class should contain copyright mark: Copyright (c) 2023 BeyondTheCloud.Dev
