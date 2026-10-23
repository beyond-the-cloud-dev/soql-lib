@IsTest
public class TestDataFactory {
    public static Account createAccount() {
        Account account = new Account(Name = 'Acme');
        insert account;
        return account;
    }

    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(AccountId = accountId, StartDate = Date.today(), ContractTerm = 12);
        insert contract;
        return contract;
    }

    public static Contact createContact(Id accountId) {
        Contact contact = new Contact(LastName = 'Doe', AccountId = accountId);
        insert contact;
        return contact;
    }

    public static Product2 createProduct() {
        Product2 product = new Product2(Name = 'Server', IsActive = true);
        insert product;
        return product;
    }

    public static PricebookEntry createPricebookEntry(Id productId) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
        return pricebookEntry;
    }

    public static Opportunity createOpportunity(Id accountId, Id contactId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Acme servers',
            AccountId = accountId,
            ContactId = contactId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opportunity;
        return opportunity;
    }

    public static OpportunityLineItem createLineItem(Id opportunityId, Id pricebookEntryId) {
        OpportunityLineItem lineItem = new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 1,
            UnitPrice = 75
        );
        insert lineItem;
        return lineItem;
    }
}
