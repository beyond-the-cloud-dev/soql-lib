public inherited sharing abstract class SObjectSelector {
    protected QS qsBuilder;

    public SObjectSelector() {
        qsBuilder = QS.of(fromSObject()).fields(standardFields());
    }

    abstract sObjectType fromSObject();

    virtual List<sObjectField> standardFields() {
        return new List<sObjectField>();
    }
}
