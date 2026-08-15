---
sidebar_position: 100
---

# Logger

Log failed queries with your own logging solution.

## Logger

Create a top-level class that implements the `SOQL.Logger` interface. The implementation is discovered automatically — no registration is needed.

**Signature**

```apex
void log(SOQL.Error error);
```

**Example**

```apex
public class SOQLLogger implements SOQL.Logger {
    public void log(SOQL.Error error) {
        System.debug(LoggingLevel.ERROR, 'Query failed: ' + error.getException().getMessage() + '\n' + error.getQuery());
        // or use your own logging framework here (e.g. Nebula Logger)
    }
}
```

## Error

`SOQL.Error` contains the details of the failed query.

**Signature**

```apex
Exception getException();
String getQuery();
Map<String, Object> getBinding();
AccessLevel getAccessLevel();
```

**Example**

```apex
public class SOQLLogger implements SOQL.Logger {
    public void log(SOQL.Error error) {
        System.debug(LoggingLevel.ERROR, error.getException().getMessage()); // No such column 'InvalidField' on entity 'Account'.
        System.debug(LoggingLevel.ERROR, error.getQuery()); // SELECT InvalidField FROM Account WHERE Name = :v1
        System.debug(LoggingLevel.ERROR, error.getBinding()); // { v1 => 'Test' }
        System.debug(LoggingLevel.ERROR, error.getAccessLevel()); // USER_MODE
    }
}
```

## How it works

- The logger is invoked only when query execution fails. The original exception is always rethrown after logging.
- The implementation is discovered via [`ApexTypeImplementor`](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_apextypeimplementor.htm) and instantiated lazily using a no-arg constructor. The first query error in a transaction triggers the discovery.
- Exactly one implementation is honored. Keep a single class implementing `SOQL.Logger` in your org.
- The class must be top-level and concrete. Inner classes are not discoverable by `ApexTypeImplementor`.
- The logger must not throw. An exception thrown inside `log()` replaces the original query error.
- Mocked exceptions (`SOQL.mock(...).throwException()`) are not logged.
