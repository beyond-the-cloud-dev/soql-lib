public with sharing class OpportunitiesSelector extends SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity.AccountId,
            Opportunity.Amount,
            Opportunity.CloseDate,
            Opportunity.Description,
            Opportunity.ExpectedRevenue,
            Opportunity.Id,
            Opportunity.Name,
            Opportunity.Pricebook2Id,
            Opportunity.Probability,
            Opportunity.StageName,
            Opportunity.Type,
            Opportunity.DiscountType__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Opportunity.sObjectType;
    }

    public List<Opportunity> selectById(Set<ID> idSet) {
        return (List<Opportunity>) selectSObjectsById(idSet);
    }

    public List<Opportunity> selectByIdWithProducts(Set<ID> idSet) {
        assertIsAccessible();

        OpportunityLineItemsSelector opportunityLineItemSelector = new OpportunityLineItemsSelector();
        PricebookEntriesSelector pricebookEntrySelector = new PricebookEntriesSelector();
        ProductsSelector productSelector = new ProductsSelector();
        PricebooksSelector pricebookSelector = new PricebooksSelector();

        opportunityLineItemSelector.assertIsAccessible();
        pricebookEntrySelector.assertIsAccessible();
        productSelector.assertIsAccessible();
        pricebookSelector.assertIsAccessible();

        String query = String.format(
            'select {0}, ' + '(select {3},{5},{6},{7} ' + 'from OpportunityLineItems ' + 'order by {4}) ' + 'from {1} ' + 'where id in :idSet ' + 'order by {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),
                getOrderBy(),
                opportunityLineItemSelector.getFieldListString(),
                opportunityLineItemSelector.getOrderBy(),
                pricebookEntrySelector.getRelatedFieldListString('PricebookEntry'),
                productSelector.getRelatedFieldListString('PricebookEntry.Product2'),
                pricebookSelector.getRelatedFieldListString('PricebookEntry.Pricebook2')
            }
        );

        return (List<Opportunity>) Database.query(query);
    }
}
