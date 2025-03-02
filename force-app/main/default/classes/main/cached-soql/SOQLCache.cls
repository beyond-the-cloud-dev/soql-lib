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
        Cacheable maxHoursWithoutRefresh(Integer hours);
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

    public static Cacheable of(SObjectType ofObject) {
        return new SOQLCache(ofObject);
    }

    public static Cacheable of(String ofObject) {
        return new SOQLCache(ofObject);
    }

    // Mocking

    public interface Mockable {
        void thenReturn(SObject record);
    }

    @TestVisible
    private static Mockable mock(String mockId) {
        queryIdToMock.put(mockId, new Mock());
        return queryIdToMock.get(mockId);
    }

    public static void removeFromCache(List<SObject> records) {
        if (records.isEmpty()) {
            return;
        }

        String ofObject = records[0].getSObjectType().toString();

        // Record deletion will trigger an automatic cache refresh when the query is executed.
        new CacheStorageProxy(ofObject).apexTransaction().removeRecordsFromCache(records);
        new CacheStorageProxy(ofObject).orgCache().removeRecordsFromCache(records);
        new CacheStorageProxy(ofObject).sessionCache().removeRecordsFromCache(records);
    }

    // Back support

    @TestVisible  // deprecated
    private static void setMock(String mockId, SObject record) {
        mock(mockId).thenReturn(record);
    }

    // Implementation

    private static Map<String, Mock> queryIdToMock = new Map<String, Mock>();

    private Executor executor;
    private Cache cache;

    public SOQL.Queryable initialQuery = null;
    public SOQL.Queryable currentyQuery = null;

    protected SOQLCache(SObjectType ofObject) {
        this(ofObject.getDescribe().getName());
    }

    protected SOQLCache(String ofObject) {
        this.initialQuery = this.initialQuery()?.systemMode()?.withoutSharing();
        this.currentyQuery = SOQL.of(ofObject).systemMode().withoutSharing();

        this.cache = new Cache(ofObject);
        this.executor = new Executor(this.currentyQuery, this.cache);

        this.with('Id');
    }

    public Cacheable cacheInApexTransaction() {
        this.cache.storage.apexTransaction();
        return this;
    }

    public Cacheable cacheInOrgCache() {
        this.cache.storage.orgCache();
        return this;
    }

    public Cacheable cacheInSessionCache() {
        this.cache.storage.sessionCache();
        return this;
    }

    public Cacheable maxHoursWithoutRefresh(Integer hours) {
        this.cache.expiration.maxRecordAgeInHours(hours);
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
        this.initialQuery?.with(fields);
        this.currentyQuery.with(fields);
        this.cache.fields.with(fields);
        return this;
    }

    public Cacheable with(String fields) {
        this.initialQuery?.with(fields);
        this.currentyQuery.with(fields);
        this.cache.fields.with(fields);
        return this;
    }

    public Cacheable whereEqual(SObjectField field, Object value) {
        return this.whereEqual(field.getDescribe().getName(), value);
    }

    public Cacheable whereEqual(String field, Object value) {
        this.with(field);
        this.cache.filter.singleFilterValidation();
        this.cache.filter.with(field).equal(value);
        this.currentyQuery.whereAre(SOQL.Filter.with(field).equal(value));
        return this;
    }

    public Cacheable stripInaccessible() {
        return this.stripInaccessible(AccessType.READABLE);
    }

    public Cacheable stripInaccessible(AccessType accessType) {
        this.currentyQuery.stripInaccessible(accessType);
        this.executor.stripInaccessible(accessType);
        return this;
    }

    public Cacheable mockId(String queryIdentifier) {
        this.currentyQuery.mockId(queryIdentifier);
        this.executor.mockId(queryIdentifier);
        return this;
    }

    public Cacheable preview() {
        this.currentyQuery.preview();
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
        this.cache.filter.hasFilterValidation();
        this.executeInitialQuery();
        return this.executor.toObject();
    }

    private void executeInitialQuery() {
        if (this.cache.storage.hasCachedRecords() || this.initialQuery == null) {
            return;
        }
        this.cache.storage.putInitialRecordsToCache(this.initialQuery.toList());
    }

    public Cacheable byId(SObject record) {
        return byId(record.Id);
    }

    public Cacheable byId(Id recordId) {
        whereEqual('Id', recordId);
        return this;
    }

    private class CacheStorageProxy {
        private CacheManager.Cacheable storage = CacheManager.ApexTransaction;
        private String ofObject;

        public CacheStorageProxy(String ofObject) {
            this.ofObject = ofObject;
        }

        public CacheStorageProxy apexTransaction() {
            this.storage = CacheManager.ApexTransaction;
            return this;
        }

        public CacheStorageProxy orgCache() {
            this.storage = CacheManager.SOQLOrgCache;
            return this;
        }

        public CacheStorageProxy sessionCache() {
            this.storage = CacheManager.SOQLSessionCache;
            return this;
        }

        public void putInitialRecordsToCache(List<SObject> records) {
            List<CacheItem> cacheRecords = new List<CacheItem>();

            for (SObject record : records) {
                cacheRecords.add(new CacheItem(record));
            }

            this.putRecordsToCache(cacheRecords);
        }

        public void putRecordsToCache(List<CacheItem> records) {
            this.storage.put(this.ofObject, records);
        }

        public Boolean hasCachedRecords() {
            return this.storage.contains(this.ofObject);
        }

        public List<CacheItem> getCachedRecords() {
            return (List<CacheItem>) (this.storage.get(this.ofObject) ?? new List<CacheItem>());
        }

        public void addRecordsToCache(List<SObject> recordsToAdd) {
            List<CacheItem> allCachedRecords = getCachedRecords();

            for (SObject databaseRecord : recordsToAdd) {
                allCachedRecords.add(new CacheItem(databaseRecord));
            }

            putRecordsToCache(allCachedRecords);
        }

        public void updateRecordsInCache(List<SObject> recordsToUpdate) {
            List<CacheItem> allCachedRecords = getCachedRecords();

            for (SObject updatedRecord : recordsToUpdate) {
                for (CacheItem cachedRecord : allCachedRecords) {
                    if (updatedRecord.Id == cachedRecord.id) {
                        cachedRecord.record = updatedRecord;
                        cachedRecord.cachedDate = System.now();
                    }
                }
            }

            putRecordsToCache(allCachedRecords);
        }

        public void removeRecordsFromCache(List<SObject> recordsToRemove) {
            Set<Id> recordsToRemoveIds = new Map<Id, SObject>(recordsToRemove).keySet();
            List<CacheItem> allCachedRecords = getCachedRecords();
            List<CacheItem> filteredCachedItems = new List<CacheItem>();

            for (CacheItem cachedRecord : allCachedRecords) {
                if (!recordsToRemoveIds.contains(cachedRecord.id)) {
                    filteredCachedItems.add(cachedRecord);
                }
            }

            putRecordsToCache(filteredCachedItems);
        }
    }

    private class Cache {
        public CacheFilter filter;
        public CacheStorageProxy storage;
        public CacheFields fields;
        public CacheExpiration expiration;

        public Cache(String ofObject) {
            this.filter = new CacheFilter(ofObject);
            this.storage = new CacheStorageProxy(ofObject);
            this.fields = new CacheFields();
            this.expiration = new CacheExpiration();
        }

        private List<CacheItem> cachedItemsThatMeetCriteria {
            get {
                if (this.cachedItemsThatMeetCriteria == null) {
                    this.cachedItemsThatMeetCriteria = this.filter.filter(this.storage.getCachedRecords());
                }
                return this.cachedItemsThatMeetCriteria;
            }
            private set;
        }

        public List<SObject> toList() {
            List<SObject> records = new List<SObject>();

            for (CacheItem cachedRecord : this.cachedItemsThatMeetCriteria) {
                records.add(cachedRecord.record);
            }

            return records;
        }

        public void save(List<SObject> databaseRecords) {
            List<CacheItem> newCacheRecords = new List<CacheItem>();

            if (this.isRecordMissingFromCache()) {
                storage.addRecordsToCache(databaseRecords);
            } else if (databaseRecords.isEmpty()) { // record does not exist in database anymore
                storage.removeRecordsFromCache(this.toList());
            } else if (this.areRequestedFieldsMissing() || this.areRecordsOutdated()) {
                storage.updateRecordsInCache(databaseRecords);
            }
        }

        public Boolean isRecordMissingFromCache() {
            return this.cachedItemsThatMeetCriteria.isEmpty();
        }

        public Boolean areRequestedFieldsMissing() {
            return !this.fields.haveAllRequestedFields(this.cachedItemsThatMeetCriteria);
        }

        public Boolean areRecordsOutdated() {
            return !this.expiration.areRecordsRecentEnough(this.cachedItemsThatMeetCriteria);
        }
    }

    @TestVisible
    private class CacheItem {
        public Id id;
        public DateTime cachedDate;
        public SObject record;

        public CacheItem(SObject record) {
            this.id = record.Id;
            this.cachedDate = System.now();
            this.record = record;
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

        public List<CacheItem> filter(List<CacheItem> cachedItems) {
            List<CacheItem> cacheItemsThatMeetCriteria = new List<CacheItem>();

            for (CacheItem cacheItem : cachedItems) {
                if (cacheItem.record.get(this.field) == this.value) {
                    cacheItemsThatMeetCriteria.add(cacheItem);
                }
            }

            return cacheItemsThatMeetCriteria;
        }
    }

    private class CacheFields {
        private Set<String> cachedFields = new Set<String>();

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

        public Boolean haveAllRequestedFields(List<CacheItem> cachedItems) {
            for (CacheItem cachedItem : cachedItems) {
                if (!this.hasAllRequestedFields(cachedItem.record)) {
                    return false;
                }
            }
            return true;
        }

        public Boolean hasAllRequestedFields(SObject record) {
            Boolean hasCachedFields = true;
            for (String field : this.cachedFields) {
                hasCachedFields &= record.isSet(field);
            }
            return hasCachedFields;
        }
    }

    private class CacheExpiration {
        private Integer maxRecordAgeInHours = 48;

        public void maxRecordAgeInHours(Integer hours) {
            this.maxRecordAgeInHours = hours;
        }

        public Boolean areRecordsRecentEnough(List<CacheItem> cachedItems) {
            for (CacheItem cachedItem : cachedItems) {
                if (!isRecentEnough(cachedItem)) {
                    return false;
                }
            }

            return true;
        }

        public Boolean isRecentEnough(CacheItem cachedItem) {
            Decimal recordAgeInHoursSinceCached = (System.now().getTime() - cachedItem.cachedDate.getTime()) / (1000 * 60 * 60);
            return recordAgeInHoursSinceCached <= this.maxRecordAgeInHours;
        }
    }

    public class Mock implements Mockable {
        private List<SObject> mockedRecords = null;

        public void thenReturn(SObject record) {
            this.mockedRecords = new List<SObject>{ record };
        }

        public List<SObject> getMockedResult() {
            return mockedRecords;
        }
    }

    private inherited sharing class Executor {
        private SOQL.Queryable currentyQuery;
        private Cache cache;
        private AccessType accessType = null;
        private String mockId;

        public Executor(SOQL.Queryable currentyQuery, Cache cache) {
            this.currentyQuery = currentyQuery;
            this.cache = cache;
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
            if (queryIdToMock.containsKey(mockId)) {
                return queryIdToMock.get(mockId).getMockedResult();
            }

            List<SObject> records = this.cache.toList();

            if (
                this.cache.isRecordMissingFromCache() ||
                this.cache.areRequestedFieldsMissing() ||
                this.cache.areRecordsOutdated()
            ) {
                records = this.currentyQuery.toList(); // SOQL query execution
                cache.save(records);
            }

            if (this.accessType == null) {
                return records;
            }

            return Security.stripInaccessible(this.accessType, records).getRecords();
        }
    }

    public class SoqlCacheException extends Exception {}
}
