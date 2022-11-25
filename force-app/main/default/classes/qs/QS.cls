public inherited sharing abstract class QS extends QB {
    public QS(sObjectType objectType) {
        super(objectType);
    }

    protected sObject getSObjectsById(Id recordId) {
        return this.condition(new QB_ConditionsGroup().add(new QB_Condition().equal(recordId))).toSObject();
    }

    protected List<sObject> getSObjectsByIds(List<Id> recordIds) {
        return this.condition(new QB_ConditionsGroup().add(new QB_Condition().inCollection(recordIds))).toSObjects();
    }
}
