public with sharing class LeadSourceReport {
    public static Map<String, Integer> countLeadsBySource() {
        List<SOQL.AggregateResultProxy> results = SOQL.of(Lead.SObjectType)
            .with(Lead.LeadSource)
            .count(Lead.Id, 'total')
            .groupBy(Lead.LeadSource)
            .mockId('LeadSourceReport.countLeadsBySource')
            .toAggregatedProxy();

        Map<String, Integer> leadCountBySource = new Map<String, Integer>();
        for (SOQL.AggregateResultProxy result : results) {
            leadCountBySource.put((String) result.get('LeadSource'), (Integer) result.get('total'));
        }
        return leadCountBySource;
    }
}
