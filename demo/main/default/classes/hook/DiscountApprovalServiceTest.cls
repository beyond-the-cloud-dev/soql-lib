@IsTest
private class DiscountApprovalServiceTest {
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
}
