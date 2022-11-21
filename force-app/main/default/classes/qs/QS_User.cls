public with sharing class QS_User extends QS {
    public QS_User() {
        super(User.sObjectType);
    }

    public User getById(Id userId) {
        return (User) this.getSObjectsById(userId);
    }

    public List<User> getByIds(List<Id> userIds) {
        return (List<User>) this.getSObjectsByIds(userIds);
    }

    public User toObject() {
        return (User) this.toSObject();
    }

    public List<User> toList() {
        return (List<User>) this.toSObjectList();
    }
}
