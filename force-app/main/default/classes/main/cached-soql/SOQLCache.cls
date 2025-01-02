public abstract inherited sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // CONFIG
        Cacheable cacheInApexTransaction();
        Cacheable cacheInOrgCache();
        Cacheable cacheInSessionCache();
        // WHERE
        Cacheable whereEqual(SObjectField field, Object value);
        Cacheable whereEqual(String field, Object value);
        // FIELD-LEVEL SECURITY
        Cacheable stripInaccessible();
        Cacheable stripInaccessible(AccessType accessType);
        // MOCKING
        Cacheable mockId(String queryIdentifier);
        // DEBUGGING
        Cacheable preview();
        // PREDEFINED
        Cacheable byId(SObject record);
        Cacheable byId(Id recordId);
        // RESULT
        Id toId();
        Boolean doExist();
        SObject toObject();
        Object toValueOf(SObjectField fieldToExtract);
    }

    protected abstract List<SObjectField> cachedFields();

    protected virtual SOQL.Queryable initialQuery() {
        return null;
    }

    @TestVisible
    private static void setMock(String mockId, SObject record) {
        mock.setMock(mockId, new List<SObject>{ record });
    }

    // Implementation

    private static Mock mock = new Mock();

    private Builder builder;
    private CacheExecutor executor;

    protected SOQLCache(SObjectType ofObject) {
        this.builder = new Builder(ofObject.getDescribe().getName());
        this.executor = new CacheExecutor(this.builder);

        this.populateQuery(this.initialQuery());
        this.setCachedFields(this.cachedFields());
    }

    private Cacheable populateQuery(SOQL.Queryable query) {
        this.builder.initialQuery = query?.systemMode()?.withoutSharing();
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

    private Cacheable setCachedFields(List<SObjectField> cachedFields) {
        this.builder.initialQuery?.with(cachedFields);
        this.builder.currentyQuery.with(cachedFields);
        this.builder.cacheFilter.cachedFields(cachedFields);
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

    public Cacheable stripInaccessible() {
        return this.stripInaccessible(AccessType.READABLE);
    }

    public Cacheable stripInaccessible(AccessType accessType) {
        this.builder.currentyQuery.stripInaccessible(accessType);
        this.executor.stripInaccessible(accessType);
        return this;
    }

    public Cacheable mockId(String queryIdentifier) {
        this.builder.currentyQuery.mockId(queryIdentifier);
        this.executor.mockId(queryIdentifier);
        return this;
    }

    public Cacheable preview() {
        this.builder.currentyQuery.preview();
        return this;
    }

    public Id toId() {
        return this.toObject().Id;
    }

    public Boolean doExist() {
        return this.toObject() != null;
    }

    public Object toValueOf(SObjectField fieldToExtract) {
        if (!this.cachedFields().contains(fieldToExtract)) {
            throw new SoqlCacheException('The field to extract must be cached.');
        }
        return this.toObject()?.get(fieldToExtract);
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

    public Cacheable byId(SObject record) {
        return byId(record.Id);
    }

    public Cacheable byId(Id recordId) {
        whereEqual('Id', recordId);
        return this;
    }

    private class Builder {
        public String ofObject;
        public CacheFilter cacheFilter = null;
        public CacheStorageProxy storage = null;
        public SOQL.Queryable initialQuery = null;
        public SOQL.Queryable currentyQuery = null;

        public Builder(String ofObject) {
            this.ofObject = ofObject;
            this.storage = new CacheStorageProxy(this.ofObject);
            this.cacheFilter = new CacheFilter(this.ofObject);
            this.currentyQuery = SOQL.of(this.ofObject).systemMode().withoutSharing();
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
            this.storage.put(this.key(), value);
        }

        public Boolean hasCachedRecords() {
            return this.storage.contains(this.key());
        }

        public Object getCachedRecords() {
            return this.storage.get(this.key());
        }

        private String key() {
            return Test.isRunningTest() ? this.ofObject + 'Test' : this.ofObject;
        }
    }

    private class CacheFilter {
        private String ofObject;
        private String field;
        private Object value;
        private List<String> cachedFields = new List<String>();

        public CacheFilter(String ofObject) {
            this.ofObject = ofObject;
        }

        public CacheFilter cachedFields(List<SObjectField> fields) {
            for (SObjectField cachedField : fields) {
                this.cachedFields.add(cachedField.getDescribe().getName());
            }
            return this;
        }

        public CacheFilter with(String field) {
            this.field = field;
            this.fieldValidation();
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

        private void fieldValidation() {
            if (!this.cachedFields.contains(this.field)) {
                throw new SoqlCacheException('Filter must use cached field. Updated cached fields in cachedFilelds() method or update the condition.');
            }

            if (!(new List<String>{ 'Id', 'Name', 'DeveloperName' }.contains(this.field) || Schema.getGlobalDescribe().get(this.ofObject).getDescribe().fields.getMap().get(this.field).getDescribe().isUnique())) {
                throw new SoqlCacheException('Cached query can be filter only by Id, Name, DeveloperName or a unique field.');
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
    }

    private class Mock {
        private final Map<String, List<SObject>> sObjectsMocks = new Map<String, List<SObject>>();

        public void setMock(String mockId, List<SObject> records) {
            sObjectsMocks.put(mockId, records);
        }

        public Boolean hasMock(String mockId) {
            return sObjectsMocks.containsKey(mockId);
        }

        public List<SObject> getSObjectsMock(String mockId) {
            return sObjectsMocks.get(mockId);
        }
    }

    private inherited sharing class CacheExecutor {
        private Builder builder;
        private AccessType accessType = null;
        private String mockId;

        public CacheExecutor(Builder builder) {
            this.builder = builder;
        }

        public void stripInaccessible(AccessType type) {
            accessType = type;
        }

        public void mockId(String id) {
            mockId = id;
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
            if (mock.hasMock(mockId)) {
                return mock.getSObjectsMock(mockId);
            }

            List<SObject> cachedRecords = (List<SObject>) this.builder.storage.getCachedRecords();
            cachedRecords = cachedRecords == null ? new List<SObject>() : cachedRecords;
            List<SObject> records = this.builder.cacheFilter.filter(cachedRecords);

            if (records.isEmpty()) {
                records = this.builder.currentyQuery.toList();
                cachedRecords.addAll(records);
                this.builder.storage.putRecordsToCache(records);
            }

            if (this.accessType == null) {
                return records;
            }

            return Security.stripInaccessible(this.accessType, records).getRecords();
        }
    }

    public class SoqlCacheException extends Exception {}
}
