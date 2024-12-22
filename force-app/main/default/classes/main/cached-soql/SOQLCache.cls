public abstract with sharing class SOQLCache implements Cacheable {
    public interface Selector {
        Cacheable query();
    }

    public interface Cacheable {
        // WHERE
        Cacheable whereAre(SOQLCache.Filter filter);
        // RESULT
        SObject toObject();
    }

    public interface Filter {
        // FIELDS
        Filter id();
        Filter name();
        Filter with(SObjectField field);
        Filter with(String field);
        // COMPERATORS
        Filter equal(Object value);
        // TODO isTrue
        // TODO isFalse

        Condition getCondition();
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
        this.cacheRecordsFromInitialQueryIfCacheEmpty();
        for (SObjectField field : this.cachedFields()) {
            this.cachedFields.add(field + '');
        }
    }

    private void cacheRecordsFromInitialQueryIfCacheEmpty() {
        if (this.cacheIn().contains(this.ofObject) || this.initialQuery() == null) {
            return;
        }
        this.cacheIn().put(this.ofObject, this.initialQuery().with(this.cachedFields()).toList());
    }

    public Cacheable whereAre(SOQLCache.Filter filter) {
        // TODO throw exception that there can be only one condition
        if (this.filterCondition != null) {
            // throw new Error(Only one condition can be used)
        }

        // TODO Check if record has all cachedFields
        if (!this.cachedFields.contains(this.filterCondition.getCondition().field)) {
            // throw new Error(Filters must use cached fields. Updated cached fields in cachedFilelds() or change condition)
        }

        // TODO Field should be unique otherwise it doesn't make sense to filtr
        // not sure if it's possible

        this.filterCondition = filter;
        this.currentQuery.whereAre(SOQL.Filter.with(this.filterCondition.getCondition().field).equal(this.filterCondition.getCondition().value));

        return this;
    }

    public SObject toObject() {
        if (this.filterCondition == null) {
            // TODO throw Error (One condition is required)
        }

        List<SObject> cachedRecords = (List<SObject>) this.cacheIn().get(this.ofObject);

        if (cachedRecords == null) {
            SObject record = this.currentQuery.toObject(); // SOQL
            this.cacheIn().put(this.ofObject, new List<SObject>{ record });
            return record;
        }

        for (SObject record : cachedRecords) {
            if (record.get(this.filterCondition.getCondition().field) == this.filterCondition.getCondition().value) { // find record in cache
                return record;
            }
        }

        // TODO record not found in cache
        // add it to existing records
        SObject record = this.currentQuery.toObject();
        cachedRecords.add(record);
        this.cacheIn().put(this.ofObject, cachedRecords);

        return record;
    }

    private class SoqlFilter implements Filter {
        private Condition condition;

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
            this.condition.field = field;
            return this;
        }

        public Filter equal(Object value) {
            return set('=', value);
        }

        private Filter set(String comperator, Object value) {
            this.condition.value = value;
            this.condition.comperator = comperator;
            return this;
        }

        public Condition getCondition() {
            return this.condition;
        }
    }

    private class Condition {
        public String field;
        public String comperator;
        public Object value;
    }
}

/*
1. Catch error when there is no available space.
2. Catch error when ord doesn't support platform cache.
3. You can't mock platform cache partition in Apex tests.

SOQL Cache

1. It has to be cached by unique field. Why? If there is no record in cache that meet filter criteria, then SOQL know that it should be pull from database. If SOQL Lib try to find record by not unique value and there are some records in cache, soql lib
cannot be sure that's all of them or just a part.
*/
