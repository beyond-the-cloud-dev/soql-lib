public inherited sharing class QS_Contact extends SObjectSelector {
    public sObjectType fromSObject() {
        return Contact.sObjectType;
    }

    public void globalQueryConfig() {
        selector.fields(new List<sObjectField>{
            Contact.Name,
            Contact.FirstName,
            Contact.LastName
        });
    }

    public List<Contact> getAll() {
        return (List<Contact>) selector
            .fields(new List<sObjectField>{
                Contact.Name,
                Contact.FirstName,
                Contact.LastName
            })
            .orderBy(Contact.Name)
            .setLimit(1000)
            .preview()
            .asList();
    }

    public Contact getById(Id contactId) {
        return (Contact) selector
            .whereAre(QS.ConditionGroup
                .add(QS.Condition.field(Contact.Id).equal(contactId))
            )
            .preview()
            .asObject();
    }

    public List<Contact> getByIds(List<Id> contactIds) {
        return (List<Contact>) selector
            .whereAre(QS.ConditionGroup
                .add(QS.Condition.field(Contact.Id).inCollection(contactIds))
            )
            .preview()
            .asList();
    }
}