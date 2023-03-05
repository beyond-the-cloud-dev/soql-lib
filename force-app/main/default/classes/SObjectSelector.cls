public inherited sharing abstract class SObjectSelector {
    protected QS qsBuilder;

    public SObjectSelector() {
        qsBuilder = QS.of(fromSObject());
        globalConfig();
    }

    abstract sObjectType fromSObject();

    virtual void globalConfig() {}
}
