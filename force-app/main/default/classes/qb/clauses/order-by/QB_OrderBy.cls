public class QB_OrderBy extends QB_QueryClause {

    private static final String ASC_ORDER = 'ASC';
    private static final String DESC_ORDER = 'DESC';
    private static final String FIRST = 'FIRST';
    private static final String LAST = 'LAST';

    private String sortingField;
    private String sortingOrder;
    private String nullsOrder;

    public QB_OrderBy setField(sObjectField sortingFields) {
        return this.setField(sortingFields.getDescribe().getName());
    }

    public QB_OrderBy setField(String sortingFields) {
        this.sortingField = sortingFields;
        return this;
    }

    public QB_OrderBy setAscOrder() {
        return this.setResultOrder(ASC_ORDER);
    }

    public QB_OrderBy setDescOrder() {
        return this.setResultOrder(DESC_ORDER);
    }

    private QB_OrderBy setResultOrder(String sortingOrder) {
        this.sortingOrder = sortingOrder;
        return this;
    }

    public QB_OrderBy setNullsFirstOrder() {
        return this.setNullsOrder(FIRST);
    }

    public QB_OrderBy setNullsLastOrder() {
        return this.setNullsOrder(LAST);
    }

    private QB_OrderBy setNullsOrder(String nullsOrder) {
        this.nullsOrder = nullsOrder;
        return this;
    }

    public override String build() {
        String orderByStatement = 'ORDER BY ' + this.sortingField + ' ' + this.sortingOrder;

        if (String.isNotEmpty(this.nullsOrder)) {
            orderByStatement += ' NULLS ' + this.nullsOrder;
        }

        return orderByStatement;
    }
}
