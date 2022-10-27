public class QB_From extends QB_QueryClause {

    private String objectApiName;

    public QB_From(String objectApiName) {
        this.objectApiName = objectApiName;
    }

    public QB_From(sObjectType objectType) {
        this.objectApiName = objectType.getDescribe().getName();
    }

    public override String build() {
        return 'FROM ' + objectApiName + ' \n';
    }

    public override Integer getPosition() {
        return 3;
    }
}
