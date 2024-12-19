public abstract with sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // SELECT
        Cacheable with(SObjectField field);
        Cacheable with(SObjectField field1, SObjectField field2);
        Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3);
        Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
        Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
        // Cacheable with(List<SObjectField> fields);
        // Cacheable with(Iterable<String> fields);
        // Cacheable with(String fields);
        // WHERE
        Cacheable whereAre(SOQL.Filter filter);
        // RESULT
        SObject toObject();
        List<SObject> toList();
    }

    public interface Filter {
        // create own filter, because only equal will be supported
        // create adapter that translate SOQLCache.Filter to SOQL.Filter
    }

    private static final Map<StorageType, CacheStorage> STORAGE_TYPE_TO_SERVICE = new Map<StorageType, CacheStorage> {
        StorageType.APEX_TRANSACTION => new TransactionCacheStorage(),
        StorageType.SESSION_CACHE => new TransactionCacheStorage(),
        StorageType.ORG_CACHE => new TransactionCacheStorage()
    };

    private SOQL.Queryable query;
    private String ofObject;
    private CacheStorage cacheStorage;

    public SOQLCache(SObjectType ofObject) {
        this.ofObject = ofObject.getDescribe().getName();
        this.query = SOQL.of(this.ofObject);
        this.cacheStorage = STORAGE_TYPE_TO_SERVICE.get(this.cacheIn());

        // check if cache is empty if yes, execute initial query
        initialQuery().toList();
    }

    public Cacheable with(SObjectField field) {
        this.query.with(field);
        return this;
    }

    public Cacheable with(SObjectField field1, SObjectField field2) {
        this.query.with(field1, field2);
        return this;
    }

    public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3) {
        this.query.with(field1, field2, field3);
        return this;
    }

    public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
        this.query.with(field1, field2, field3, field4);
        return this;
    }

    public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
        this.query.with(field1, field2, field3, field4, field5);
        return this;
    }

    public Cacheable with(List<SObjectField> fields) {
        this.query.with(fields);
        return this;
    }

    public Cacheable with(Iterable<String> fields) {
        this.query.with(fields);
        return this;
    }

    public Cacheable with(String fields) {
        this.query.with(fields);
        return this;
    }

    public Cacheable whereAre(SOQL.Filter filter) {
        // check if filter field is cachedByFields, if not throw an error
        this.query.whereAre(filter);
        return this;
    }

    public SObject toObject() {
        // here logic to retrieve form cache
        // if not cached then execute query and add to cache
        return this.query.toObject();
    }

    public List<SObject> toList() {
        // here logic to retrieve form cache
        // if not cached then execute query and add to cache
        List<SObject> records = null;//cacheStorage.get(this.ofObject, );

        if (records == null) {
            records = this.query.toList();
            cacheValues(records);
        }

        return records;
    }

    private void cacheValues(List<SObject> records) {
        Map<String, List<SObject>> aggregatedRecordsByFieldValueKey = new Map<String, List<SObject>>();

        for (SObjectField cacheKeyField : cachedBy()) {
            for (SObject record : records) {
                String key = cacheKeyField + '.' + record.get(cacheKeyField);

                if (!aggregatedRecordsByFieldValueKey.containsKey(key)) {
                    aggregatedRecordsByFieldValueKey.put(key, new List<SObject>());
                }

                aggregatedRecordsByFieldValueKey.get(key).add(record);
            }
        }

        this.cacheStorage.put(this.ofObject, aggregatedRecordsByFieldValueKey);
    }

    private List<SObject> getCachedRecords() {
        // return this.cacheStorage.put(this.ofObject, aggregatedRecordsByFieldValueKey);


        return null;
    }

    public virtual StorageType cacheIn() {
        return StorageType.APEX_TRANSACTION;
    }

    public virtual SOQL.Queryable initialQuery() {
        return null;
    }

    public abstract List<SObjectField> cachedBy();
    public abstract List<SObjectField> cachedFields();

    public enum StorageType {
        APEX_TRANSACTION,
        SESSION_CACHE,
        ORG_CACHE
    }

    public interface CacheStorage {
        List<SObject> get(String objectApiName, String field, Object value);
        void put(String objectApiName,Map<String, List<SObject>> values);
    }

    private class TransactionCacheStorage implements CacheStorage {
        private Map<String, Map<String, List<SObject>>> cachePartition = new Map<String, Map<String, List<SObject>>>();

        public List<SObject> get(String objectApiName, String field, Object value) {
            Map<String, List<SObject>> cachedValues = (Map<String, List<SObject>>) cachePartition.get(objectApiName);

            if (cachedValues == null) {
                return null;
            }

            return cachedValues.get(field + '.' + value);
        }

        public void put(String objectApiName, Map<String, List<SObject>> values) {
            cachePartition.put(objectApiName, values);
        }
    }

    private class SessionCacheStorage implements CacheStorage {
        private Cache.Partition cachePartition = Cache.Session.getPartition('local.SOQLCache');

        public List<SObject> get(String objectApiName, String field, Object value) {
            Map<String, List<SObject>> cachedValues = (Map<String, List<SObject>>) cachePartition.get(objectApiName);

            if (cachedValues == null) {
                return null;
            }

            return cachedValues.get(field + '.' + value);
        }

        public void put(String objectApiName, Map<String, List<SObject>> values) {
            cachePartition.put(objectApiName, values);
        }
    }

    private class OrgCacheStorage implements CacheStorage {
        private Cache.Partition cachePartition = Cache.Org.getPartition('local.SOQLCache');

        public List<SObject> get(String objectApiName, String field, Object value) {
            Map<String, List<SObject>> cachedValues = (Map<String, List<SObject>>) cachePartition.get(objectApiName);

            if (cachedValues == null) {
                return null;
            }

            return cachedValues.get(field + '.' + value);
        }

        public void put(String objectApiName, Map<String, List<SObject>> values) {
            cachePartition.put(objectApiName, values);
        }
    }
}

// Map<String, List<SObject>> values = new Map<String, List<SObject>>();
// String field = 'Name';
// String objectApiName = 'Profile';
// List<SObject> records = [SELECT Id, Name, UserType FROM Profile LIMIT 3];

// for (String fieldToCache : new List<String>{ 'Id', 'Name', 'UserType' }) {
//     for (SObject record : records) {
//         String key = fieldToCache + '.' + record.get(fieldToCache);

//         if (!values.containsKey(key)) {
//             values.put(key, new List<SObject>());
//         }

//         values.get(key).add(record);
//     }
// }

// Cache.Partition cachePartition = Cache.Org.getPartition('local.SOQLCache');
// cachePartition.put(objectApiName, values);
// Map<String, List<SObject>> hehe =  (Map<String, List<SObject>>) cachePartition.get('Profile');
// System.debug(LoggingLevel.DEBUG, ': ' + JSON.SerializePretty(hehe));


// Cache.Partition cachePartition = Cache.Org.getPartition('local.SOQLCache');
// Map<String, List<SObject>> hehe =  (Map<String, List<SObject>>) cachePartition.get('ss');
// System.debug('hehe >>' + hehe);
