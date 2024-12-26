public abstract with sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // CONFIG
        Cacheable initialQuery(SOQL.Queryable query);
        Cacheable cacheInApexTransaction();
        Cacheable cacheInOrgCache();
        Cacheable cacheInSessionCache();
        // SELECT
        Cacheable with(List<SObjectField> fields);
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

    // Implementation

    private Builder builder;
    private CacheExecutor executor;

    public SOQLCache(SObjectType ofObject) {
        this.builder = new Builder(ofObject.getDescribe().getName());
        this.executor = new CacheExecutor(this.builder);
    }

    public Cacheable initialQuery(SOQL.Queryable query) {
        this.builder.initialQuery = query;
        return this;
    }

    public Cacheable cacheInApexTransaction() {
        this.builder.storage.cacheInApexTransaction();
        return this;
    }

    public Cacheable cacheInOrgCache() {
        this.builder.storage.cacheInOrgCache();
        return this;
    }

    public Cacheable cacheInSessionCache() {
        this.builder.storage.cacheInSessionCache();
        return this;
    }

    public Cacheable with(List<SObjectField> cachedFields) {
        this.builder.initialQuery.with(cachedFields);
        this.builder.currentyQuery.with(cachedFields);
        this.builder.cacheFilter.withCachedFields(cachedFields);
        return this;
    }

    public Cacheable whereEqual(SObjectField field, Object value) {
        return this.whereEqual(field.getDescribe().getName(), value);
    }

    public Cacheable whereEqual(String field, Object value) {
        this.builder.cacheFilter.singleFilterValidation();
        this.builder.cacheFilter.with(field).equal(value);
        this.builder.currentyQuery.whereAre(SOQL.Filter.with(field).equal(value));
        return this;
    }

    public Cacheable mockId(String id) {
        this.builder.currentyQuery.mockId(id);
        return this;
    }

    public SObject toObject() {
        this.builder.cacheFilter.hasFilterValidation();
        this.executeInitialQuery();
        return this.executor.toObject();
    }

    private void executeInitialQuery() {
        if (this.builder.storage.hasCachedRecords() || this.builder.initialQuery == null) {
            return;
        }
        this.builder.storage.putRecordsToCache(this.builder.initialQuery.toList());
    }

    public SObject byId(Id recordId) {
        return whereEqual('Id', recordId).toObject();
    }

    private class Builder {
        public String ofObject;
        public CacheFilter cacheFilter = null;
        public CacheStorageProxy storage = null;
        public SOQL.Queryable initialQuery = null;
        public SOQL.Queryable currentyQuery = null;

        public Builder(String ofObject) {
            this.ofObject = ofObject;
            this.currentyQuery = SOQL.of(this.ofObject);
            this.cacheFilter = new CacheFilter(this.ofObject);
            this.storage = new CacheStorageProxy(this.ofObject);
        }
    }

    private class CacheStorageProxy {
        private CacheManager.Cacheable storage = CacheManager.ApexTransaction;
        private String ofObject;

        public CacheStorageProxy(String ofObject) {
            this.ofObject = ofObject;
        }

        public void cacheInApexTransaction() {
            this.storage = CacheManager.ApexTransaction;
        }

        public void cacheInOrgCache() {
            this.storage = CacheManager.SOQLOrgCache;
        }

        public void cacheInSessionCache() {
            this.storage = CacheManager.SOQLSessionCache;
        }

        public void putRecordsToCache(Object value) {
            this.storage.put(this.ofObject, value);
        }

        public Boolean hasCachedRecords() {
            return this.storage.contains(this.ofObject);
        }

        public Object getCachedRecords() {
            return this.storage.get(this.ofObject);
        }
    }

    private class CacheFilter {
        private String ofObject;
        private String field;
        private Object value;
        private List<String> fieldsToCache = new List<String>();

        public CacheFilter(String ofObject) {
            this.ofObject = ofObject;
        }

        public CacheFilter withCachedFields(List<SObjectField> fields) {
            for (SObjectField cachedField : fields) {
                this.fieldsToCache.add(cachedField.getDescribe().getName());
            }
            return this;
        }

        public CacheFilter with(String field) {
            this.validate();
            this.field = field;
            return this;
        }

        public CacheFilter equal(Object value) {
            this.value = value;
            return this;
        }

        public void singleFilterValidation() {
            if (String.isNotBlank(this.field)) {
                throw new SoqlCacheException('Only one condition can be used in cached selector.');
            }
        }

        public void hasFilterValidation() {
            if (String.isBlank(this.field)) {
                throw new SoqlCacheException('Condition is missing. Provide filter to retrieve cached record.');
            }
        }

        public List<SObject> filter(List<SObject> cachedRecords) {
            List<SObject> filteredRecords = new List<SObject>();

            for (SObject record : cachedRecords) {
                if (record.get(this.field) == this.value) {
                    filteredRecords.add(record);
                }
            }

            return filteredRecords;
        }

        private void validate() {
            if (!this.fieldsToCache.contains(this.field)) {
                throw new SoqlCacheException('Filter must use cached field. Updated cached fields in cachedFilelds() method or update the condition.');
            }

            if (!(new List<String>{ 'Id', 'Name', 'DeveloperName' }.contains(this.field) || Schema.getGlobalDescribe().get(this.ofObject).getDescribe().fields.getMap().get(this.field).getDescribe().isUnique())) {
                throw new SoqlCacheException('Cached query can be filter only by Id, Name, DeveloperName or a unique field.');
            }
        }
    }

    private inherited sharing class CacheExecutor {
        private Builder builder;

        public CacheExecutor(Builder builder) {
            this.builder = builder;
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
            List<SObject> cachedRecords = (List<SObject>) this.builder.storage.getCachedRecords();
            cachedRecords = cachedRecords == null ? new List<SObject>() : cachedRecords;
            List<SObject> filteredCachedRecords = this.builder.cacheFilter.filter(cachedRecords);

            if (!filteredCachedRecords.isEmpty()) {
                return filteredCachedRecords;
            }

            List<SObject> databaseRecords = this.builder.currentyQuery.toList();
            cachedRecords.addAll(databaseRecords);
            this.builder.storage.putRecordsToCache(cachedRecords);

            return databaseRecords;
        }
    }

    public class SoqlCacheException extends Exception {}
}
