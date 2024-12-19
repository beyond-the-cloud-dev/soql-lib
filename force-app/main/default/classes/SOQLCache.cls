public virtual with sharing class SOQLCache extends SOQL implements Cacheable {
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
        Cacheable with(List<SObjectField> fields);
        Cacheable with(Iterable<String> fields);
        Cacheable with(String fields);
        // WHERE
        Cacheable whereAre(Filter filter);
        // RESULT

        Storage getStorage();
    }

    public SOQLCache(SObjectType ofObject) {
        super(ofObject.getDescribe().getName());
    }

    public enum Storage {
        APEX_TRANSACTION,
        SESSION_CACHE,
        ORG_CACHE
    }

    public virtual Storage getStorage() {
        return Storage.APEX_TRANSACTION;
    }

    public override SObject toObject() {
        super.toObject();
        return null;
    }

    public override List<SObject> toList() {
        super.toList();
        return null;
    }
}
