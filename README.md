# License notes:
- For proper license management each repository should contain LICENSE file similar to this one.
- each original class should contain copyright mark: © Copyright 2022, Beyond The Cloud Dev Authors

# Usage

```java
Contact myContact = new QS_Contact()
                        .withField(new List<sObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName })
                        .toWhere(new QB_Condition(Contact.Name).equal('Contact1'))
                        .toObject();
```
