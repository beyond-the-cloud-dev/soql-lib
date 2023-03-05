public inherited sharing abstract class SObjectSelector {
    protected QS qsBuilder;

    public SObjectSelector() {
        qsBuilder = QS.of(fromSObject());
        globalQueryConfig();
    }

    abstract sObjectType fromSObject();

    virtual void globalQueryConfig() {}
}
