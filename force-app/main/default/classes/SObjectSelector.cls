public inherited sharing abstract class SObjectSelector {
    protected QS selector;

    public SObjectSelector() {
        selector = QS.of(fromSObject());
        globalQueryConfig();
    }

    abstract sObjectType fromSObject();

    virtual void globalQueryConfig() {}
}
