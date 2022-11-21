public with sharing abstract class QS extends QB {
    public QS(sObjectType objectType) {
        super(objectType);
    }

    protected sObject getSObjectsById(Id recordId) {
        return this.withWhere(new QB_Condition('Id').equal(recordId)).toSObject();
    }

    protected List<sObject> getSObjectsByIds(List<Id> recordIds) {
        return this.withWhere(new QB_Condition('Id').inCollection(recordIds)).toSObjectList();
    }
}
