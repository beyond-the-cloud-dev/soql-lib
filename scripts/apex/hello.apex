List<Account> contacts = (List<Account>) QS.of(Account.sObjectType)
.fields(new List<sObjectField>{
    Account.Name
})
.whereAre(QS.ConditionGroup
    .add(QS.Condition.field(Account.Name).equal('Test 1'))
    .add(QS.Condition.field(Account.Id).equal('0013V00000WND5GQAX'))
)
.setLimit(10)
.preview()
.asList();

System.debug(LoggingLevel.DEBUG, ': ' + contacts);

// SELECT Id, Name FROM Account LIMIT 10
