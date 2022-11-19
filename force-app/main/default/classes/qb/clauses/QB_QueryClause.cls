public abstract class QB_QueryClause {

    public abstract String build();

    public virtual String validate() {
        return '';
    }
}
