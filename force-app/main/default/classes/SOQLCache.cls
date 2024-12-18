public virtual with sharing class SOQLCache extends SOQL implements Cacheable {
    interface Cacheable {
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
