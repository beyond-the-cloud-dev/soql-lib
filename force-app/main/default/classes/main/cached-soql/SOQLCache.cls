public abstract with sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // WHERE
        Cacheable whereAre(SOQLCache.Filter filter);
        // RESULT
        SObject toObject();
        List<SObject> toList();
    }

    public interface Filter {
        // create own filter, because only equal will be supported
        // create adapter that translate SOQLCache.Filter to SOQL.Filter
        // FIELDS
        Filter id();
        Filter name();
        Filter with(SObjectField field);
        Filter with(String field);
        // COMPERATORS
        Filter equal(Object value);
    }

    public static Filter Filter {
        get { return new SoqlFilter(); }
    }

    private class SoqlFilter implements Filter {
        private String field;
        private String comperator;
        private Object value;

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
            this.value = value;
            this.comperator = comperator;
            return this;
        }
    }

    public virtual CacheManager.Cacheable cacheIn() {
        return CacheManager.ApexTransaction;
    }

    public virtual SOQL.Queryable initialQuery() {
        return null;
    }

    public abstract List<SObjectField> cachedFields();

    // Implementation

    private SOQL.Queryable query;
    private Filter condition;
    private String ofObject;

    public SOQLCache(SObjectType ofObject) {
        this.ofObject = ofObject.getDescribe().getName();
        this.query = SOQL.of(this.ofObject).with(cachedFields());

        if (!this.cacheIn().contains(this.ofObject)) {
            initialQuery().toList();
            // cache those values
        }
    }

    public Cacheable with(String fields) {
        this.query.with(fields);
        return this;
    }

    public Cacheable whereAre(SOQLCache.Filter filter) {
        if (condition == null) {
            this.condition = filter;
            return this;
        }

        // throw exception that there can be only one condition
        // throw exception if filter field is cachedByFields, if not throw an error

        // adapter
        // this.query.whereAre(filter);
        return this;
    }

    public SObject toObject() {
        List<SObject> cachedRecords = (List<SObject>) this.cacheIn().get(this.ofObject);

        if (cachedRecords == null) {
            SObject record = this.query.toObject(); // SOQL
            this.cacheIn().put(this.ofObject, new List<SObject>{ record });
            return record;
        }

        for (SObject record : cachedRecords) {
            if (record.get(this.filter.field) == this.filter.value) { // find record in cache
                return record;
            }
        }

        // record not found in cache
        // add it to existing records
        SObject record = this.query.toObject();
        cachedRecords.add(record);
        this.cacheIn().put(this.ofObject, cachedRecords);

        return record;
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


/*
1. Catch error when there is no available space.
2. Catch error when ord doesn't support platform cache.
3. You can't mock platform cache partition in Apex tests.

SOQL Cache

1. It has to be cached by unique field. Why? If there is no record in cache that meet filter criteria, then SOQL know that it should be pull from database. If SOQL Lib try to find record by not unique value and there are some records in cache, soql lib
cannot be sure that's all of them or just a part.
*/
