@IsTest
private class LegacyDiscountApprovalServiceTest {
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
}
