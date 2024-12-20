public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    }

    public override StorageType cacheIn() {
        return StorageType.ORG_CACHE;
    }

    public override List<SObjectField> cachedBy() {
        return new List<SObjectField>{ Profile.Id, Profile.Name };
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType };
    }

    public Profile byId(Id profileId) {
        whereAre(SOQLCache.Filter.with(Profile.Id).equal(profileId));
        return (Profile) toObject();
    }

    public Profile byName(String name) {
        whereAre(SOQLCache.Filter.with(Profile.Name).equal(name));
        return (Profile) toObject();
    }
}
