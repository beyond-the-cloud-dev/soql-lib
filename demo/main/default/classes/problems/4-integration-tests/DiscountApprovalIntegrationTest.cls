@IsTest
private class DiscountApprovalIntegrationTest {
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
}
