

# Usage

```java
Contact myContact = new QS_Contact()
                        .withField(new List<sObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName })
                        .toWhere(new QB_Condition(Contact.Name).equal('Contact1'))
                        .toObject();
```

# Benefits

1. No *List has no rows for assignment to SObject* error. When record not found value will be null.

```java
Contact myContact = [SELECT Id, Name FROM Contact WHERE Name = 'invalidName']; // Error: List has no rows for assignment to SObject

Contact myContact = new QS_Contact()
                        .withFields(new List<sObjectField>{ Contact.Id, Contact.Name })
                        .withWhere(new QB_Condition(Contact.Name).equal('invalidName'))
                        .toObject(); // null
```

2.

# TODO

- [ ] SOQL Query Performance sugestion
- [ ] QB_TestMock
- [ ] Custom Metadata for debugging on production
- [ ] Skip condition when null (?)

# License notes:
- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors
