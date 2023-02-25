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

List<Account> contacts2 = (List<Account>) QS.of(Account.sObjectType)
.fields(new List<sObjectField>{
    Account.Name
})
.whereAre(QS.ConditionGroup
    .add(QS.Condition.field(Account.Name).equal('Test 2'))
    .add(QS.Condition.field(Account.Id).equal('0013V00000WND5GQAY'))
)
.setLimit(10)
.preview()
.asList();




// SELECT Id, Name FROM Account LIMIT 10

// sub-query
List<Account> contacts2 = (List<Account>) QS.of(Account.sObjectType)
.fields(new List<sObjectField>{
    Account.Name
})
.subQuery(
    QS.SubQuery.of('Contacts')
    .fields(new List<sObjectField>{
        Contact.FirstName, Contact.LastName
    })
)
.whereAre(QS.ConditionGroup
    .add(QS.Condition.field(Account.Name).equal('Test 2'))
    .add(QS.Condition.field(Account.Id).equal('0013V00000WND5GQAY'))
)
.setLimit(10)
.preview()
.asList();
