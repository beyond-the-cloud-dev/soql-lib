public with sharing class QB_Binding {
    public List<Object> valuesToBind = new List<Object>();

    public Boolean hasConditions() {
        return !this.valuesToBind.isEmpty();
    }

    public String bind(Object variable) {
        this.valuesToBind.add(variable);

        return 'binding' + String.valueof(this.valuesToBind.size() - 1);
    }

    public void initEmpty() {
        this.valuesToBind.addAll(new Object[10 - this.valuesToBind.size()]);
    }

    public Object get(Integer index) {
        return this.valuesToBind.get(index);
    }
}


// System.debug(
//     new QB(Account.sObjectType)
//         .condition(new QB_Condition(Account.Name).equal('Test 1'))
//         .condition(new QB_Condition(Account.Name).equal('Test 2'))
//         .condition(new QB_Condition(Account.Name).equal('Test 2'))
//         .condition(
//             new QB_ConditionsGroup()
//             .condition(new QB_Condition(Account.Name).equal('Test 1'))
//             .condition(new QB_Condition(Account.Name).equal('Test 2'))
//         )
//         .conditionsOrder('1 OR 2 OR 3 OR 4')
// );
// System.debug(new QB(Account.sObjectType).condition(new QB_Condition(Account.Name).equal('Test 1')).build());
