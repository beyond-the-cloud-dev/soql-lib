public with sharing class DiscountApprovalService {
    private static final Integer KEY_ACCOUNT_MIN_WON_DEALS = 3;
    private static final Decimal KEY_ACCOUNT_MAX_DISCOUNT = 0.30;
    private static final Decimal STANDARD_MAX_DISCOUNT = 0.20;

    public static Boolean needsApproval(Opportunity opportunity) {
        Integer wonDeals = SOQL.of(Opportunity.SObjectType)
            .count()
            .whereAre(SOQL.Filter.with(Opportunity.AccountId).equal(opportunity.AccountId))
            .whereAre(SOQL.Filter.with(Opportunity.IsWon).isTrue())
            .toInteger();
        Decimal maxDiscount = wonDeals >= KEY_ACCOUNT_MIN_WON_DEALS ? KEY_ACCOUNT_MAX_DISCOUNT : STANDARD_MAX_DISCOUNT;

        List<OpportunityLineItem> lineItems = SOQL.of(OpportunityLineItem.SObjectType)
            .with(OpportunityLineItem.UnitPrice)
            .with('PricebookEntry', PricebookEntry.UnitPrice)
            .whereAre(SOQL.Filter.with(OpportunityLineItem.OpportunityId).equal(opportunity.Id))
            .toList();

        for (OpportunityLineItem lineItem : lineItems) {
            Decimal floorPrice = lineItem.PricebookEntry.UnitPrice * (1 - maxDiscount);
            if (lineItem.UnitPrice < floorPrice) {
                return true;
            }
        }
        return false;
    }
}
