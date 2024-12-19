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

    private SOQL.Queryable query;
    private Storage storageType = Storage.APEX_TRANSACTION;

    public SOQLCache(SObjectType ofObject) {
        this.query = SOQL.of(ofObject.getDescribe().getName());

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
        return this.query.toList();
    }

    public virtual Storage cacheIn() {
        return Storage.APEX_TRANSACTION;
    }

    public virtual SOQL.Queryable initialQuery() {
        return null;
    }

    public abstract List<SObjectField> cachedBy();

    public enum Storage {
        APEX_TRANSACTION,
        SESSION_CACHE,
        ORG_CACHE
    }
}
