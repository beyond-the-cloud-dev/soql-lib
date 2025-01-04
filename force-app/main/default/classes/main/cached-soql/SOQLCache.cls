/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
 * - ExcessivePublicCount: It is a library class and exposes all necessary methods to construct a query
 * - ExcessiveClassLength: It is a library and we tried to put everything into ONE class
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - PropertyNamingConventions: It was intentional to make the lib more fluent and readable
 * - FieldDeclarationsShouldBeAtStart: Developer who uses lib should see what's important at start
 * - ApexDoc: Variable names are self-documented.
 * - ExcessiveParameterList - Make methods similar to native SOQL
**/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.ExcessiveClassLength, PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.PropertyNamingConventions, PMD.FieldDeclarationsShouldBeAtStart, PMD.ApexDoc, PMD.ExcessiveParameterList')
public virtual inherited sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // CONFIG
        Cacheable cacheInApexTransaction();
        Cacheable cacheInOrgCache();
        Cacheable cacheInSessionCache();
        // SELECT
        Cacheable with(SObjectField field);
        Cacheable with(SObjectField field1, SObjectField field2);
        Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3);
        Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        Cacheable with(List<SObjectField> fields);
        Cacheable with(String fields);
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

    protected virtual SOQL.Queryable initialQuery() {
        return null;
    }

    @TestVisible
    private static void setMock(String mockId, SObject record) {
        mock.setMock(mockId, new List<SObject>{ record });
    }

    public static Cacheable of(SObjectType ofObject) {
        return new SOQLCache(ofObject);
    }

    // Implementation

    private static Mock mock = new Mock();

    private Builder builder;
    private Executor executor;

    protected SOQLCache(SObjectType ofObject) {
        this.builder = new Builder(ofObject.getDescribe().getName());
        this.executor = new Executor(this.builder);

        this.populateQuery(this.initialQuery());
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

    public Cacheable with(SObjectField field1) {
        return this.with(new List<SObjectField>{ field1 });
    }

    public Cacheable with(SObjectField field1, SObjectField field2) {
        return this.with(new List<SObjectField>{ field1, field2 });
    }

    public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3) {
        return this.with(new List<SObjectField>{ field1, field2, field3 });
    }

    public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
        return this.with(new List<SObjectField>{ field1, field2, field3, field4 });
    }

    public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
        return this.with(new List<SObjectField>{ field1, field2, field3, field4, field5 });
    }

    public Cacheable with(List<SObjectField> fields) {
        this.builder.initialQuery?.with(fields);
        this.builder.currentyQuery.with(fields);
        this.builder.cacheFields.with(fields);
        return this;
    }

    public Cacheable with(String fields) {
        this.builder.initialQuery?.with(fields);
        this.builder.currentyQuery.with(fields);
        this.builder.cacheFields.with(fields);
        return this;
    }

    public Cacheable whereEqual(SObjectField field, Object value) {
        return this.whereEqual(field.getDescribe().getName(), value);
    }

    public Cacheable whereEqual(String field, Object value) {
        this.with(field);
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
        this.with(fieldToExtract);
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
        public CacheFilter cacheFilter = null;
        public CacheFields cacheFields = new CacheFields();
        public CacheStorageProxy storage = null;
        public SOQL.Queryable initialQuery = null;
        public SOQL.Queryable currentyQuery = null;

        public Builder(String ofObject) {
            this.storage = new CacheStorageProxy(ofObject);
            this.cacheFilter = new CacheFilter(ofObject);
            this.currentyQuery = SOQL.of(ofObject).systemMode().withoutSharing();
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

        public CacheFilter(String ofObject) {
            this.ofObject = ofObject;
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
                throw new SoqlCacheException('Only one condition can be used in a cached query.');
            }
        }

        public void hasFilterValidation() {
            if (String.isBlank(this.field)) {
                throw new SoqlCacheException('A condition is missing. Please provide a filter to retrieve the cached record.');
            }
        }

        private void fieldValidation() {
            if (!(new List<String>{ 'Id', 'Name', 'DeveloperName' }.contains(this.field) || this.isFilterFieldUnique())) {
                throw new SoqlCacheException('A cached query can be filtered only by Id, Name, DeveloperName, or a unique field.');
            }
        }

        private Boolean isFilterFieldUnique() {
            return Schema.getGlobalDescribe().get(this.ofObject).getDescribe().fields.getMap().get(this.field).getDescribe().isUnique();
        }

        public List<SObject> filter(List<SObject> cachedRecords) {
            List<SObject> records = new List<SObject>();

            for (SObject record : cachedRecords) {
                if (record.get(this.field) == this.value) {
                    records.add(record);
                }
            }

            return records;
        }
    }

    private class CacheFields {
        private Set<String> cachedFields = new Set<String>{ 'Id' };

        public void with(String fields) {
            for (String field : fields.split(',')) {
                this.cachedFields.add(field.trim());
            }
        }

        public void with(List<SObjectField> fields) {
            for (SObjectField field : fields) {
                this.cachedFields.add(field.getDescribe().getName());
            }
        }

        public Boolean hasAllCachedFields(List<SObject> records) {
            for (SObject record : records) {
                if (!this.hasAllCachedFields(record)) {
                    return false;
                }
            }
            return true;
        }

        public Boolean hasAllCachedFields(SObject record) {
            Boolean hasCachedFields = true;
            for (String field : this.cachedFields) {
                hasCachedFields &= record.isSet(field);
            }
            return hasCachedFields;
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

    private inherited sharing class Executor {
        private Builder builder;
        private AccessType accessType = null;
        private String mockId;

        public Executor(Builder builder) {
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

        private List<SObject> toList() {
            if (mock.hasMock(mockId)) {
                return mock.getSObjectsMock(mockId);
            }

            List<SObject> cachedRecords = (List<SObject>) this.builder.storage.getCachedRecords() ?? new List<SObject>();
            List<SObject> recordsFilterFromCache = this.builder.cacheFilter.filter(cachedRecords);

            if (recordsFilterFromCache.isEmpty()) {
                List<SObject> databaseRecords = this.builder.currentyQuery.toList(); // SOQL
                this.insertRecordsToCache(cachedRecords, databaseRecords);

                return this.stripInaccessible(databaseRecords);
            }

            if (!this.builder.cacheFields.hasAllCachedFields(recordsFilterFromCache)) {
                List<SObject> databaseRecords = this.builder.currentyQuery.toList(); // SOQL
                this.updateRecordsInCache(cachedRecords, databaseRecords);

                return this.stripInaccessible(databaseRecords);
            }

            return this.stripInaccessible(recordsFilterFromCache);
        }

        private void insertRecordsToCache(List<SObject> cachedRecords, List<SObject> databaseRecords) {
            cachedRecords.addAll(databaseRecords);
            this.builder.storage.putRecordsToCache(cachedRecords);
        }

        private void updateRecordsInCache(List<SObject> cachedRecords, List<SObject> databaseRecords) {
            for (SObject databaseRecord : databaseRecords) {
                for (SObject cachedRecord : cachedRecords) {
                    if (databaseRecord.Id == cachedRecord.Id) {
                        cachedRecord = databaseRecord;
                    }
                }
            }
            this.builder.storage.putRecordsToCache(cachedRecords);
        }

        private List<SObject> stripInaccessible(List<SObject> records) {
            if (this.accessType == null) {
                return records;
            }

            return Security.stripInaccessible(this.accessType, records).getRecords();
        }
    }

    public class SoqlCacheException extends Exception {}
}
