public with sharing class LegacyDiscountApprovalService {
    private static final Integer KEY_ACCOUNT_MIN_WON_DEALS = 3;
    private static final Decimal KEY_ACCOUNT_MAX_DISCOUNT = 0.30;
    private static final Decimal STANDARD_MAX_DISCOUNT = 0.20;

    public static Boolean needsApproval(Opportunity opportunity) {
        Integer wonDeals = [
            SELECT COUNT()
            FROM Opportunity
            WHERE AccountId = :opportunity.AccountId AND IsWon = true
        ];
        Decimal maxDiscount = wonDeals >= KEY_ACCOUNT_MIN_WON_DEALS ? KEY_ACCOUNT_MAX_DISCOUNT : STANDARD_MAX_DISCOUNT;

        for (OpportunityLineItem lineItem : [
            SELECT UnitPrice, PricebookEntry.UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunity.Id
        ]) {
            Decimal floorPrice = lineItem.PricebookEntry.UnitPrice * (1 - maxDiscount);
            if (lineItem.UnitPrice < floorPrice) {
                return true;
            }
        }
        return false;
    }
}
