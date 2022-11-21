public class QB_From extends QB_QueryClause {

    private String objectApiName;

    public QB_From(sObjectType objectType) {
        this.objectApiName = objectType.getDescribe().getName();
    }

    public QB_From(String objectApiName) { // for sub-query
        this.objectApiName = objectApiName;
    }

    public override String build() {
        return 'FROM ' + objectApiName;
    }
}
