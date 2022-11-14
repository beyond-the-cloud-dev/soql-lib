public class QB_From extends QB_QueryClause {

    private String objectApiName;

    public QB_From(String objectApiName) {
        this.objectApiName = objectApiName;
    }

    public override String build() {
        return 'FROM ' + objectApiName;
    }

    public override Integer getPosition() {
        return 3;
    }
}
