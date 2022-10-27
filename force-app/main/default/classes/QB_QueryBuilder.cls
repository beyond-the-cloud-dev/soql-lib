public class QB_QueryBuilder extends QB_QueryClause {

    protected Set<QB_QueryUnit> queryParts;

    public QB_From(sObjectType objectType) {
        this.queryParts = new Set<QB_QueryUnit>{ new QB_Fields(), new QB_From(fromObject) };
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
