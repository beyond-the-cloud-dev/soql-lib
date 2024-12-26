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

    private String ofObject;
    private SOQL.Queryable query;
    private CacheExecutor executor;
    private CacheFilter cacheFilter = null;

    public SOQLCache(SObjectType ofObject) {
        this.ofObject = ofObject.getDescribe().getName();
        this.query = SOQL.of(this.ofObject).with(this.cachedFields());
        this.cacheFilter = new CacheFilter(this.ofObject, this.cachedFields());
        this.executor = new CacheExecutor(this.ofObject, this.cacheIn(), this.cacheFilter, this.query);

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
        // if (String.isNotBlank(this.field)) {
        //     throw new SoqlCacheException('Only one condition can be used in cached selector.');
        // }

        this.cacheFilter.with(field).equal(value);
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

        return this.executor.toObject();
    }

    public SObject byId(Id recordId) {
        return whereEqual('Id', recordId).toObject();
    }

    private class CacheFilter {
        private String ofObject;
        private String field;
        private Object value;
        private List<String> fieldsToCache = new List<String>();

        public CacheFilter(String ofObject, List<SObjectField> fieldsToCache) {
            for (SObjectField cachedField : fieldsToCache) {
                this.fieldsToCache.add(cachedField.getDescribe().getName());
            }
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

        public List<SObject> filter(List<SObject> cachedRecords) {
            this.validate();

            List<SObject> filteredRecords = new List<SObject>();

            for (SObject record : cachedRecords) {
                if (record.get(this.field) == this.value) {
                    filteredRecords.add(record);
                }
            }

            return filteredRecords;
        }
    }

    private inherited sharing class CacheExecutor {
        private String ofObject;
        private CacheFilter cacheFilter;
        private CacheManager.Cacheable storage;
        private SOQL.Queryable query;

        public CacheExecutor(String ofObject, CacheManager.Cacheable storage, CacheFilter cacheFilter, SOQL.Queryable query) {
            this.ofObject = ofObject;
            this.storage = storage;
            this.cacheFilter = cacheFilter;
            this.query = query;
        }

        public SObject toObject() {
            List<SObject> records = this.toList();

            if (records.size() > 1) {
                throw new QueryException('List has more than 1 row for assignment to SObject');
            }

            if (records.size() == 0) {
                return null;
            }

            return records[0];
        }

        public List<SObject> toList() {
            List<SObject> cachedRecords = (List<SObject>) this.storage.get(this.ofObject);
            cachedRecords = cachedRecords == null ? new List<SObject>() : cachedRecords;
            List<SObject> filteredCachedRecords = this.cacheFilter.filter(cachedRecords);

            if (!filteredCachedRecords.isEmpty()) {
                return filteredCachedRecords;
            }

            List<SObject> databaseRecords = this.query.toList();
            cachedRecords.addAll(databaseRecords);
            this.storage.put(this.ofObject, cachedRecords);

            return databaseRecords;
        }
    }

    public class SoqlCacheException extends Exception {}
}
