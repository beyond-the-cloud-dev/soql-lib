public abstract with sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // WHERE
        Cacheable whereEqual(SObjectField field, Object value);
        Cacheable whereEqual(String field, Object value);
        // MOCKING
        Cacheable mockId(String id);
        // PREDEFINED
        SObject byId(Id recordId);
        // RESULT
        SObject toObject();
    }

    public virtual SOQL.Queryable initialQuery() {
        return null;
    }

    public virtual CacheManager.Cacheable cacheIn() {
        return CacheManager.ApexTransaction;
    }

    public abstract List<SObjectField> cachedFields();

    // Implementation

    private String ofObject = null;
    private SOQL.Queryable query = null;
    private CacheFilter cacheFilter = null;

    public SOQLCache(SObjectType ofObject) {
        this.ofObject = ofObject.getDescribe().getName();
        this.query = SOQL.of(this.ofObject).with(this.cachedFields());

        this.executeInitialQuery();
    }

    private void executeInitialQuery() {
        if (this.cacheIn().contains(this.ofObject) || this.initialQuery() == null) return;
        this.cacheIn().put(this.ofObject, this.initialQuery().with(this.cachedFields()).toList());
    }

    public Cacheable whereEqual(SObjectField field, Object value) {
        return this.whereEqual(field.getDescribe().getName(), value);
    }

    public Cacheable whereEqual(String field, Object value) {
        if (this.cacheFilter != null) {
            throw new SoqlCacheException('Only one condition can be used in cached selector.');
        }

        this.cacheFilter = new CacheFilter().ofObject(this.ofObject).cachedFields(this.cachedFields()).with(field).equal(value);
        this.query.whereAre(SOQL.Filter.with(field).equal(value));
        return this;
    }

    public Cacheable mockId(String id) {
        this.query.mockId(id);
        return this;
    }

    public SObject toObject() {
        if (this.cacheFilter == null) {
            throw new SoqlCacheException('Condition is missing. Provide filter to retrieve cached record.');
        }

        List<SObject> cachedRecords = (List<SObject>) this.cacheIn().get(this.ofObject);
        cachedRecords = cachedRecords == null ? new List<SObject>() : cachedRecords;

        SObject record = this.cacheFilter.filter(cachedRecords);

        if (record == null) {
            record = this.query.toObject();
            cachedRecords.add(record);
            this.cacheIn().put(this.ofObject, cachedRecords);
        }

        return record;
    }

    public SObject byId(Id recordId) {
        return whereEqual('Id', recordId).toObject();
    }

    private class CacheFilter {
        private List<String> fieldsToCache = new List<String>();
        private String ofObject;
        private String field;
        private Object value;

        public CacheFilter ofObject(String ofObject) {
            this.ofObject = ofObject;
            return this;
        }

        public CacheFilter cachedFields(List<SObjectField> fieldsToCache) {
            for (SObjectField cachedField : fieldsToCache) {
                this.fieldsToCache.add(cachedField.getDescribe().getName());
            }
            return this;
        }

        public CacheFilter with(String field) {
            this.field = field;
            return this;
        }

        public CacheFilter equal(Object value) {
            this.value = value;
            return this;
        }

        private void validate() {
            if (!this.fieldsToCache.contains(this.field)) {
                throw new SoqlCacheException('Filter must use cached field. Updated cached fields in cachedFilelds() method or update the condition.');
            }

            if (!(new List<String>{ 'Id', 'Name', 'DeveloperName' }.contains(this.field) || Schema.getGlobalDescribe().get(this.ofObject).getDescribe().fields.getMap().get(this.field).getDescribe().isUnique())) {
                throw new SoqlCacheException('Cached query can be filter only by unique field.');
            }
        }

        public SObject filter(List<SObject> cachedRecords) {
            this.validate();
            List<SObject> records = filterToList(cachedRecords);

            if (records.size() > 1) {
                throw new QueryException('List has more than 1 row for assignment to SObject');
            }

            if (records.size() == 0) {
                return null;
            }

            return records[0];
        }

        public List<SObject> filterToList(List<SObject> cachedRecords) {
            List<SObject> filteredRecords = new List<SObject>();
            for (SObject record : cachedRecords) {
                if (record.get(this.field) == this.value) {
                    filteredRecords.add(record);
                }
            }
            return filteredRecords;
        }
    }

    public class SoqlCacheException extends Exception {}
}

/*
1. Only one condition can be use and it should filter by "unique" field - so if records is not found, query lib will know what to retrieve.
2.


TODO
1. Cache by related field (?)
 I cannot pull by list/set because part of records can be in cache, part not in cache
 or maybe I can pull records that are not in cache
*/

/*
1. Catch error when there is no available space.
2. Catch error when ord doesn't support platform cache.
3. You can't mock platform cache partition in Apex tests.

SOQL Cache

1. It has to be cached by unique field. Why? If there is no record in cache that meet filter criteria, then SOQL know that it should be pull from database. If SOQL Lib try to find record by not unique value and there are some records in cache, soql lib
cannot be sure that's all of them or just a part.
*/


//
