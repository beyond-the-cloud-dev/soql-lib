public abstract with sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // WHERE
        Cacheable whereAre(SOQLCache.Filter filter);
        // Cacheable whereEqual(String field, Object value); ??? because only equal is supported
        // RESULT
        SObject toObject();
        SObject byId(Id recordId);
        // I cannot pull by list/set because part of records can be in cache, part not in cache
        // or maybe I can pull records that are not in cache
    }

    public interface Filter {
        // FIELDS
        Filter id();
        Filter name();
        Filter with(SObjectField field);
        Filter with(String field);
        // COMPERATORS
        Filter equal(Object value);

        String getField();
        Object getValue();
    }

    public static Filter Filter {
        get { return new SoqlFilter(); }
    }

    public virtual CacheManager.Cacheable cacheIn() {
        return CacheManager.ApexTransaction;
    }

    public virtual SOQL.Queryable initialQuery() {
        return null;
    }

    public abstract List<SObjectField> cachedFields();

    // Implementation

    private SOQL.Queryable currentQuery;
    private Filter filterCondition = null;
    private String ofObject;
    private List<String> cachedFields = new List<String>();

    public SOQLCache(SObjectType ofObject) {
        this.ofObject = ofObject.getDescribe().getName();
        this.currentQuery = SOQL.of(this.ofObject).with(cachedFields());
        this.cacheRecordsFromInitialQuery();
        for (SObjectField field : this.cachedFields()) {
            this.cachedFields.add(field + '');
        }
    }

    private void cacheRecordsFromInitialQuery() {
        if (this.cacheIn().contains(this.ofObject) || this.initialQuery() == null) {
            return;
        }
        this.cacheIn().put(this.ofObject, this.initialQuery().with(this.cachedFields()).toList());
    }

    public Cacheable whereAre(SOQLCache.Filter filter) {
        if (this.filterCondition != null) {
            throw new SoqlCacheException('Only one condition can be used in cached selector.');
        }

        if (!this.cachedFields.contains(this.filterCondition.getField())) {
            throw new SoqlCacheException('Filter must use cached field. Updated cached fields in cachedFilelds() method or update the condition.');
        }

        if (new List<String>{ 'Id', 'Name', 'DeveloperName' }.contains(this.filterCondition.getField())) { // TODO || this.fieldCondition.getField().isUnique()
            throw new SoqlCacheException('Cached query can be filter only by unique field.');
        }

        this.filterCondition = filter;
        this.currentQuery.whereAre(SOQL.Filter.with(this.filterCondition.getField()).equal(this.filterCondition.getValue()));

        return this;
    }

    public SObject toObject() {
        if (this.filterCondition == null) {
            throw new SoqlCacheException('Condition is missing. Provide filter to retrieve cached record.');
        }

        List<SObject> cachedRecords = this.getCachedRecords();
        SObject record = this.findInCache(cachedRecords);

        if (record == null) {
            record = this.currentQuery.toObject();
            cachedRecords.add(record);
            this.cacheIn().put(this.ofObject, cachedRecords);
        }

        return record;
    }

    public SObject byId(Id recordId) {
        return whereAre(Filter.id().equal(recordId)).toObject();
    }

    private List<SObject> getCachedRecords() {
        List<SObject> cachedRecords = (List<SObject>) this.cacheIn().get(this.ofObject);
        return cachedRecords == null ? new List<SObject>() : cachedRecords;
    }

    public SObject findInCache(List<SObject> cachedRecords) {
        for (SObject record : cachedRecords) {
            if (record.get(this.filterCondition.getField()) == this.filterCondition.getValue()) {
                return record;
            }
        }
        return null;
    }

    private class SoqlFilter implements Filter {
        private String field;
        private Object value;
        private String comperator;

        public Filter id() {
            return with('Id');
        }

        public Filter name() {
            return with('Name');
        }

        public Filter with(SObjectField field) {
            return with(field.getDescribe().getName());
        }

        public Filter with(String field) {
            this.field = field;
            return this;
        }

        public Filter equal(Object value) {
            return set('=', value);
        }

        private Filter set(String comperator, Object value) {
            this.comperator = comperator;
            this.value = value;
            return this;
        }

        public String getField() {
            return this.field;
        }

        public Object getValue() {
            return this.value;
        }
    }

    public class SoqlCacheException extends Exception {}
}

/*
1. Only one condition can be use and it should filter by "unique" field - so if records is not found, soql lib will know what to retrieve.
2.


*/

/*
1. Catch error when there is no available space.
2. Catch error when ord doesn't support platform cache.
3. You can't mock platform cache partition in Apex tests.

SOQL Cache

1. It has to be cached by unique field. Why? If there is no record in cache that meet filter criteria, then SOQL know that it should be pull from database. If SOQL Lib try to find record by not unique value and there are some records in cache, soql lib
cannot be sure that's all of them or just a part.
*/
