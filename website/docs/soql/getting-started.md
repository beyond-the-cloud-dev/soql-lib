---
sidebar_position: 10
---

# Getting Started

The main module of the SOQL Lib consists of two concepts: **SOQL Builder** and **SOQL Selectors**.

## SOQL Builder

Our library does not force developers to create selectors. Queries can be built directly via fluent API provided by the lib.

```apex
// SELECT Id FROM Account WITH USER_MODE
List<Account> accounts = SOQL.of(Account.SObjectType).toList();
```

```apex
// SELECT Id, Name, Industry FROM Account WITH USER_MODE
List<Account> accounts = SOQL.of(Account.SObjectType)
   .with(Account.Id, Account.Name, Account.Industry)
   .toList();
```

## SOQL Selectors _(Recommended)_

However, we recommend building a selector per `SObjectType`. 

Selectors allow you to set default SOQL settings for a given `SObjectType` and keep all reusable queries in one place.
Check how to build a selector in the [Build Your Selector](./build-selector.md) section.

```apex title="SOQL_Contact.cls"
public inherited sharing class SOQL_Contact extends SOQL implements SOQL.Selector {
    public static SOQL_Contact query() {
        return new SOQL_Contact();
    }

    private SOQL_Contact() {
        super(Contact.SObjectType);
        // default settings
        with(Contact.Id, Contact.Name, Contact.AccountId);
        systemMode();
        withoutSharing();
    }

    public SOQL_Contact byAccountId(Id accountId) {
        whereAre(Filter.with(Contact.AccountId).equal(accountId));
        return this;
    }

    public SOQL_Contact bySource(String source) {
        whereAre(Filter.with(Contact.ContactSource).equal(source));
        return this;
    }
}
```

```apex title="Selector Usage"
List<Contact> contacts = SOQL_Contact.query()
    .byAccountId(...)
    .bySource('Web')
    .with(Contact.Email)
    .toList();
```


