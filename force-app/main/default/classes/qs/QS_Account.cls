public with sharing class QS_Account extends QS {
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
        return (Account) this.toSObject();
    }

    public List<Account> toList() {
        return (List<Account>) this.toSObjectList();
    }
}
