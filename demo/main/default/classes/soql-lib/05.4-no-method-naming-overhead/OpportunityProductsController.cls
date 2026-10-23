public with sharing class OpportunityProductsController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesWithProducts(List<Id> opportunityIds) {
        return SOQL_Opportunity.query()
            .with(Opportunity.Name, Opportunity.Amount, Opportunity.StageName, Opportunity.CloseDate)
            .with(SOQL.SubQuery.of('OpportunityLineItems')
                .with(OpportunityLineItem.Quantity, OpportunityLineItem.UnitPrice, OpportunityLineItem.TotalPrice)
                .with('PricebookEntry.Product2', Product2.Name, Product2.ProductCode)
                .with('PricebookEntry.Pricebook2', Pricebook2.Name)
            )
            .byIds(opportunityIds)
            .toList();
    }
}
