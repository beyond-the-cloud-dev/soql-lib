public inherited sharing class QS_Account extends QS {
    public QS_Account() {
        super(Account.sObjectType);
    }

    public Account getById(Id accountId) {
        return (Account) this.getSObjectsById(accountId);
    }

    public List<Account> getByIds(List<Id> accountIds) {
        return (List<Account>) this.getSObjectsByIds(accountIds);
    }

    public Account toObject() {
        return (Account) this.toObject();
    }

    public List<Account> toList() {
        return (List<Account>) this.toList();
    }
}


// new QS_Account().fields(new List<sObjectField>{ Account.Name }).toSObjects();
Sting name = 'Test'
new QS_Account()
    .fields(QB.Fields
        .add(Account.Name)
        .add(Account.Id)
    )
    .condition(QB.Conditions
        .field(Account.Name).equal(name)
        .field(Account.Name).equal('Test')
        .field(Account.Name).equal('Test')
        .group(QB.Conditions
            .field(Account.Name).equal('Test'),
            .order('1 OR 2')
        )
        .order('1 AND 2 OR 3 AND 4')
    )
    .setLimit(10)
    .asList();

//     .asObject();


// QS.of(Account.class)


public List<Acc> getByIds(List<Id> ids) {
    String query = 'Id IN :ids';

    Database.query(query)
}


public class QS_Account extends QS {
    public override sObjectType of() {
        return Account.sObjectType;
    }


}


public class QS {

    private sObjectType ofObject;

    public static QS of(sObjectType ofObject) {
        return new QS(ofObject);
    }

    private QS(sObjectType ofObject) {
        this.ofObject = ofObject;
    }


}

QS.of(Account.sObjecType)
    .fields()
