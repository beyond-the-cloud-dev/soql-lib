public with sharing class LegacyAccountSearchController {
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(AccountFilter filter, String sortField, String sortDirection, Integer pageSize, Integer pageNumber) {
        String query = 'SELECT Id, Name, Industry, Type, BillingCity, AnnualRevenue FROM Account';
        query += buildWhereClause(filter);
        query += ' ORDER BY ' + sortField + ' ' + sortDirection + ' NULLS LAST';
        query += ' LIMIT ' + pageSize + ' OFFSET ' + (pageNumber - 1) * pageSize;
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Integer countAccounts(AccountFilter filter) {
        return Database.countQuery('SELECT COUNT() FROM Account' + buildWhereClause(filter));
    }

    private static String buildWhereClause(AccountFilter filter) {
        List<String> conditions = new List<String>();

        if (String.isNotBlank(filter.name)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(filter.name) + '%\'');
        }
        if (String.isNotBlank(filter.industry)) {
            conditions.add('Industry = \'' + String.escapeSingleQuotes(filter.industry) + '\'');
        }
        if (String.isNotBlank(filter.billingCity)) {
            conditions.add('BillingCity = \'' + String.escapeSingleQuotes(filter.billingCity) + '\'');
        }
        if (filter.minAnnualRevenue != null) {
            conditions.add('AnnualRevenue >= ' + filter.minAnnualRevenue);
        }
        if (filter.types != null && !filter.types.isEmpty()) {
            List<String> quotedTypes = new List<String>();
            for (String accountType : filter.types) {
                quotedTypes.add('\'' + String.escapeSingleQuotes(accountType) + '\'');
            }
            conditions.add('Type IN (' + String.join(quotedTypes, ', ') + ')');
        }

        return conditions.isEmpty() ? '' : ' WHERE ' + String.join(conditions, ' AND ');
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
