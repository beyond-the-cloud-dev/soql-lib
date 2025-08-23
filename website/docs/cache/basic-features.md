---
sidebar_position: 15
---

# Basic Features

## Cache Storage Options

SOQLCache provides three different cache storage levels, each with different scope and persistence:

```apex
// Cache in Apex Transaction - fastest, limited to current transaction
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInApexTransaction()
    .toObject();
```

```apex
// Cache in Org Cache - persists across transactions and users
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInOrgCache()
    .toObject();
```

```apex
// Cache in Session Cache - persists for user session
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .cacheInSessionCache()
    .toObject();
```

## Auto-refresh After Hours

**Default: 48 hours**

All cached records have an additional field called `cachedDate`. To avoid using outdated records, you can configure `maxHoursWithoutRefresh` to automatically refresh stale cache entries:

```apex
// Auto-refresh cache after 12 hours
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .maxHoursWithoutRefresh(12)
    .toObject();
```

```apex
// Custom refresh interval in cached selector
public inherited sharing class SOQL_CachedProfile extends SOQLCache implements SOQLCache.Selector {
    private SOQL_CachedProfile() {
        super(Profile.SObjectType);
        with(Profile.Id, Profile.Name, Profile.UserType)
            .cacheInOrgCache()
            .maxHoursWithoutRefresh(24); // Refresh daily
    }
}
```

## Cached Selectors

Cached selectors extend SOQLCache and provide default cache configurations, fields, and reusable methods. Each cached selector focuses on a single SObjectType with optimal caching strategy.

```apex
public inherited sharing class SOQL_CachedProfile extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedProfile query() {
        return new SOQL_CachedProfile();
    }

    private SOQL_CachedProfile() {
        super(Profile.SObjectType);
        // Default cache configuration
        with(Profile.Id, Profile.Name, Profile.UserType)
            .cacheInOrgCache()
            .maxHoursWithoutRefresh(24);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType);
    }

    public SOQL_CachedProfile byName(String name) {
        whereEqual(Profile.Name, name);
        return this;
    }

    public SOQL_CachedProfile byUserType(String userType) {
        whereEqual(Profile.UserType, userType);
        allowFilteringByNonUniqueFields();
        return this;
    }
}
```

**Usage Example:**

```apex
// Get single profile from cache
Profile adminProfile = (Profile) SOQL_CachedProfile.query()
    .byName('System Administrator')
    .toObject();

// Check if profile exists in cache
Boolean profileExists = SOQL_CachedProfile.query()
    .byName('Standard User')
    .doExist();

// Get profile ID from cache
Id profileId = SOQL_CachedProfile.query()
    .byName('System Administrator')
    .toId();

// Extract specific field value from cache
String userType = (String) SOQL_CachedProfile.query()
    .byName('System Administrator')
    .toValueOf(Profile.UserType);
```

## Initial Query Bulk Population

The initial query allows for bulk population of records in the cache when it's empty, ensuring that subsequent queries use cached records instead of individual database queries.

**Design Philosophy:**
When the cache is empty, execute a single query to populate all commonly used records. This dramatically reduces the number of database queries for frequently accessed data like Profiles, BusinessHours, or OrgWideEmailAddress.

```apex
public inherited sharing class SOQL_CachedProfile extends SOQLCache implements SOQLCache.Selector {
    private SOQL_CachedProfile() {
        super(Profile.SObjectType);
        with(Profile.Id, Profile.Name, Profile.UserType)
            .cacheInOrgCache()
            .maxHoursWithoutRefresh(48);
    }

    public override SOQL.Queryable initialQuery() {
        // Bulk populate all profiles when cache is empty
        return SOQL.of(Profile.SObjectType);
    }
}
```

**How It Works:**
When `SOQL_CachedProfile.query().byName('System Administrator').toObject()` is called and the cache is empty, the initial query executes to populate ALL profiles in cache. Subsequent queries retrieve from cache without hitting the database.

```apex
public with sharing class ExampleController {
    @AuraEnabled
    public static Id getSystemAdminProfileId() {
        // First call: executes initial query and caches all profiles
        return SOQL_CachedProfile.query()
            .byName('System Administrator')
            .toId();
    }

    @AuraEnabled
    public static Id getStandardUserProfileId() {
        // Subsequent call: retrieves from cache, no database query
        return SOQL_CachedProfile.query()
            .byName('Standard User')
            .toId();
    }
}
```

## Field-Level Security

Unlike standard SOQL queries that use `WITH USER_MODE`, cached records require the `Security.stripInaccessible` method to enforce field-level security. This method works with both fresh query results and cached records.

### stripInaccessible

The `Security.stripInaccessible` method is the only FLS method that works with cached records, as it can remove inaccessible fields from already retrieved data.

```apex
// Apply FLS to cached records
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .stripInaccessible()
    .toObject();
```

```apex
// Apply specific AccessType
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.Name, 'System Administrator')
    .stripInaccessible(AccessType.READABLE)
    .toObject();
```

## Cache Filtering Rules

Cached queries have specific filtering requirements to ensure data consistency and performance:

### Unique Field Requirement

By default, cached queries can only filter by unique fields (`Id`, `Name`, `DeveloperName`, or schema-defined unique fields). This prevents inconsistencies between cached and database records.

```apex
// ✅ Allowed - filtering by unique field
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .whereEqual(Profile.Name, 'System Administrator')
    .toObject();
```

```apex
// ❌ Not allowed - UserType is not unique
// Throws: SoqlCacheException
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .whereEqual(Profile.UserType, 'Standard')
    .toObject();
```

### Override Filtering Rules

For specific use cases, you can override the unique field requirement:

```apex
// Allow filtering by non-unique fields
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name, Profile.UserType)
    .allowFilteringByNonUniqueFields()
    .whereEqual(Profile.UserType, 'Standard')
    .toObject();
```

### Condition Requirement

Cached queries require at least one WHERE condition to ensure specific record retrieval:

```apex
// Allow queries without conditions (for small datasets)
Profile profile = (Profile) SOQLCache.of(Profile.SObjectType)
    .with(Profile.Id, Profile.Name)
    .allowQueryWithoutConditions()
    .toObject();
```

## Mocking

SOQLCache supports mocking for unit tests. You can mock either the cached results directly or the underlying SOQL query when cache is empty. For stable tests, prefer mocking the cached results with `SOQLCache.mock()`.

### Mock Cached Results

```apex
public with sharing class ExampleController {
    public static Profile getSystemAdminProfile() {
        return (Profile) SOQL_CachedProfile.query()
            .byName('System Administrator')
            .mockId('ExampleController.getSystemAdminProfile')
            .toObject();
    }
}
```

**Test Implementation:**

```apex
@IsTest
private class ExampleControllerTest {
    @IsTest
    static void getSystemAdminProfile() {
        Profile mockProfile = new Profile(
            Id = SOQL.IdGenerator.get(Profile.SObjectType),
            Name = 'Mocked System Administrator',
            UserType = 'Standard'
        );

        // Mock the cached result
        SOQLCache.mock('ExampleController.getSystemAdminProfile').thenReturn(mockProfile);

        // Test
        Profile result = ExampleController.getSystemAdminProfile();

        Assert.areEqual('Mocked System Administrator', result.Name);
        Assert.areEqual('Standard', result.UserType);
    }
}
```

### Mock Initial Query

You can also mock the underlying SOQL query that populates the cache:

```apex
@IsTest
private class SOQL_CachedProfileTest {
    @IsTest
    static void testCachedProfileWithInitialQuery() {
        List<Profile> mockProfiles = new List<Profile>{
            new Profile(Id = SOQL.IdGenerator.get(Profile.SObjectType), Name = 'System Administrator'),
            new Profile(Id = SOQL.IdGenerator.get(Profile.SObjectType), Name = 'Standard User')
        };

        // Mock the initial query that populates cache
        SOQL.mock('initialProfileQuery').thenReturn(mockProfiles);

        // Test
        Profile result = (Profile) new SOQL_CachedProfile()
            .mockId('initialProfileQuery') 
            .byName('System Administrator')
            .toObject();

        Assert.areEqual('System Administrator', result.Name);
    }
}
```

## Cache Removal

Manual cache removal allows you to clear specific records from cache, triggering automatic refresh on the next query execution.

### Trigger-Based Cache Invalidation

```apex
trigger ProfileTrigger on Profile (after update, after delete) {
    // Clear cached profiles when they're updated or deleted
    SOQLCache.removeFromCache(Trigger.old);
}
```

### Programmatic Cache Removal

```apex
public with sharing class ProfileController {
    @AuraEnabled
    public static void updateProfileSettings(Id profileId, String newName) {
        Profile profileToUpdate = new Profile(Id = profileId, Name = newName);
        update profileToUpdate;
        
        // Remove from cache to force refresh
        SOQLCache.removeFromCache(new List<Profile>{ profileToUpdate });
    }
}
```

## Performance Benefits

SOQLCache provides significant performance improvements for frequently accessed data:

### Response Time Comparison

- **Database Query**: 50-200ms (varies by data volume and query complexity)  
- **Cache Retrieval**: 10ms (consistent performance)
- **Performance Improvement**: 5-20x faster response times

### Best Use Cases

Cache is most effective for:

**✅ Recommended Objects:**
- `Profile` - rarely changes, frequently accessed
- `BusinessHours` - static configuration data  
- `OrgWideEmailAddress` - email configuration
- `User` - when filtering by unique fields
- `CustomMetadata` - application configuration

**❌ Not Recommended For:**
- `Account`, `Contact`, `Opportunity` - high-volume, frequently changing
- Objects with complex sharing rules
- Data that changes frequently throughout the day

### Cache Storage Comparison

| Storage Type | Scope | Lifespan | Performance | Use Case |
|-------------|-------|----------|-------------|----------|
| **Apex Transaction** | Single transaction | Until transaction ends | Fastest | Repeated queries in same context |
| **Org Cache** | Organization-wide | Until manual clear/refresh | Fast | Shared metadata across users |  
| **Session Cache** | User session | Until session expires | Fast | User-specific cached data |

### Memory Usage

```apex
// Efficient - minimal fields cached
SOQL_CachedProfile.query()
    .with(Profile.Id, Profile.Name)  // Only cache needed fields
    .byName('System Administrator')
    .toObject();
```

## Cache Result Methods

SOQLCache provides streamlined result methods optimized for cached data retrieval:

### Available Result Methods

```apex
Id toId()                                    // Get record ID
Id toIdOf(SObjectField field)                // Get ID from specific field
Boolean doExist()                            // Check if record exists
Object toValueOf(SObjectField fieldToExtract) // Extract field value
SObject toObject()                           // Get single record
```

### Extract Record ID from Cache

❌ **Traditional approach:**

```apex
public static Id getSystemAdminProfileId() {
    Profile profile = [
        SELECT Id 
        FROM Profile 
        WHERE Name = 'System Administrator' 
        LIMIT 1
    ];
    return profile.Id;
}
```

✅ **With SOQLCache:**

```apex
public static Id getSystemAdminProfileId() {
    return SOQL_CachedProfile.query()
        .byName('System Administrator')
        .toId();
}
```

### Extract Field Value from Cache

❌ **Traditional approach:**

```apex
public static String getSystemAdminUserType() {
    Profile profile = [
        SELECT UserType
        FROM Profile 
        WHERE Name = 'System Administrator' 
        LIMIT 1
    ];
    return profile.UserType;
}
```

✅ **With SOQLCache:**

```apex
public static String getSystemAdminUserType() {
    return (String) SOQL_CachedProfile.query()
        .byName('System Administrator')
        .toValueOf(Profile.UserType);
}
```

### Check Record Existence in Cache

❌ **Traditional approach:**

```apex
public static Boolean hasStandardUserProfile() {
    List<Profile> profiles = [
        SELECT Id 
        FROM Profile 
        WHERE Name = 'Standard User' 
        LIMIT 1
    ];
    return !profiles.isEmpty();
}
```

✅ **With SOQLCache:**

```apex
public static Boolean hasStandardUserProfile() {
    return SOQL_CachedProfile.query()
        .byName('Standard User')
        .doExist();
}
```

### Get Related Field ID from Cache

```apex
// Get UserLicenseId from cached Profile
public static Id getProfileUserLicenseId(String profileName) {
    return SOQL_CachedProfile.query()
        .byName(profileName)
        .toIdOf(Profile.UserLicenseId);
}
```
