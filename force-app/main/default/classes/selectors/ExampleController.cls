public with sharing class ExampleController {

    public static List<Account> getAccounts() {
        return (List<Account>) QS_Account.Selector
            .fields(new List<sObjectField>{
                Account.BillingCity,
                Account.BillingCountry,
                Account.BillingCountryCode
            })
            .setLimit(1000)
            .orderBy(Account.Name)
            .preview()
            .asList();
    }

    public static List<Account> getAccounts2() {
        return (List<Account>) QS_Account.Selector
            .field(Account.BillingCity)
            .field(Account.BillingCountry)
            .field(Account.BillingCountryCode)
            .setLimit(1000)
            .orderBy(Account.Name)
            .preview()
            .asList();
    }

    public static List<Contact> getContacts() {
        return new QS_Contact().getAll();
    }
}
