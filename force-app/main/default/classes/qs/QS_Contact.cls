public with sharing class QS_Contact extends QS {
    public QS_Contact() {
        super(Contact.sObjectType);
    }

    public Contact getById(Id contactId) {
        return (Contact) this.getSObjectsById(contactId);
    }

    public List<Contact> getByIds(List<Id> contactIds) {
        return (List<Contact>) this.getSObjectsByIds(contactIds);
    }

    public Contact toObject() {
        return (Contact) this.toSObject();
    }

    public List<Contact> toList() {
        return (List<Contact>) this.toSObjectList();
    }
}
