public class QB_ConditionsGroup implements QB_ConditionClause, QB_QueryClause {
    private List<QB_ConditionClause> queryConditions = new List<QB_ConditionClause>();
    private String order = '';
    private QBB qbb;

    public QB_ConditionsGroup add(QB_ConditionClause condition) {
        condition.bindWith(qbb);
        queryConditions.add(condition);
        return this;
    }

    public QB_ConditionsGroup order(String order) {
        this.order = order;
        return this;
    }

    public void bindWith(QBB qbb) {
        this.qbb = qbb;
    }

    public String build() {
        if (queryConditions.isEmpty()) {
            return '';
        }

        if (String.isEmpty(order)) {
            setDefaultOrder();
        }

        return 'WHERE ' + buildNestedConditions();
    }

    private void setDefaultOrder() {
        List<String> defaultOrder = new List<String>();

        for (Integer i = 0; i < queryConditions.size(); i++) {
            defaultOrder.add(String.valueOf(i + 1));
        }

        order = String.join(defaultOrder, ' AND '); // e.g (1 AND 2 AND 3)
    }

    private String buildNestedConditions() {
        String orderWithSpecialCharacters = addSpecialCharactersToOrder(order); // e.g (*1* AND (*2* OR *3*))

        for (Integer i = 0; i < queryConditions.size(); i++) {
            String conditionNumber = addSpecialCharacters(String.valueOf(i + 1)); // e.g *1*

            orderWithSpecialCharacters = orderWithSpecialCharacters.replace(
                conditionNumber,
                queryConditions.get(i).build()
            );
        }

        return orderWithSpecialCharacters.replaceFirst('WHERE ', '');
    }

    private String addSpecialCharactersToOrder(String order) {
        String formattedOrder = order;

        for (Integer i = 0; i < queryConditions.size(); i++) {
            String conditionNumber = String.valueOf(i+1);

            formattedOrder = formattedOrder.replace(
                conditionNumber,
                addSpecialCharacters(conditionNumber)
            );
        }

        return '(' +formattedOrder  + ')'; // e.g (*1* AND (*2* OR *3*))
    }

    private String addSpecialCharacters(String condition) {
        return '*' + condition.trim() + '*';
    }
}
