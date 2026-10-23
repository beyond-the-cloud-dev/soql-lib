public with sharing class AccountSearchController {
    private static final Map<String, SObjectField> SORTABLE_FIELDS = new Map<String, SObjectField>{
        'Name' => Account.Name,
        'Industry' => Account.Industry,
        'BillingCity' => Account.BillingCity,
        'AnnualRevenue' => Account.AnnualRevenue
    };
    private static final Map<String, String> SORT_DIRECTIONS = new Map<String, String>{
        'ASC' => 'ASC',
        'DESC' => 'DESC'
    };

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(AccountFilter filter, String sortField, String sortDirection, Integer pageSize, Integer pageNumber) {
        return SOQL.of(Account.SObjectType)
            .with(new List<SObjectField>{ Account.Id, Account.Name, Account.Industry, Account.Type, Account.BillingCity, Account.AnnualRevenue })
            .whereAre(filtersFor(filter))
            .orderBy(SORTABLE_FIELDS.get(sortField) ?? Account.Name)
            .sort(SORT_DIRECTIONS.get(sortDirection?.toUpperCase()) ?? 'ASC')
            .nullsLast()
            .setLimit(pageSize)
            .offset((pageNumber - 1) * pageSize)
            .toList();
    }

    @AuraEnabled(cacheable=true)
    public static Integer countAccounts(AccountFilter filter) {
        return SOQL.of(Account.SObjectType)
            .whereAre(filtersFor(filter))
            .toInteger();
    }

    private static SOQL.FilterGroup filtersFor(AccountFilter filter) {
        return SOQL.FilterGroup
            .add(SOQL.Filter.name().contains(filter.name).ignoreWhen(String.isBlank(filter.name)))
            .add(SOQL.Filter.with(Account.Industry).equal(filter.industry).ignoreWhen(String.isBlank(filter.industry)))
            .add(SOQL.Filter.with(Account.BillingCity).equal(filter.billingCity).ignoreWhen(String.isBlank(filter.billingCity)))
            .add(SOQL.Filter.with(Account.AnnualRevenue).greaterOrEqual(filter.minAnnualRevenue).ignoreWhen(filter.minAnnualRevenue == null))
            .add(SOQL.Filter.with(Account.Type).isIn(filter.types).ignoreWhen(filter.types == null || filter.types.isEmpty()));
    }

    public class AccountFilter {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String industry { get; set; }
        @AuraEnabled
        public String billingCity { get; set; }
        @AuraEnabled
        public Decimal minAnnualRevenue { get; set; }
        @AuraEnabled
        public List<String> types { get; set; }
    }
}
