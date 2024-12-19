public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        // default settings
        with(Profile.Id, Profile.Name);
        withoutSharing();
    }

    public override SOQLCache.Storage getStorage() {
        return SOQLCache.Storage.ORG_CACHE;
    }

    // public override SOQL initialQuery() {
    //     return new SOQL_ProfileCache()
    // }
    public SOQL initialQuery() {
        return new SOQL_ProfileCache();
    }

    public List<SObjectField> cacheByFields() {
        return new List<SObjectField>{ Profile.Id, Profile.Name };
    }

    // if condition is not in cacheByFields throw error

    public SOQL_ProfileCache byName(String name) {
        whereAre(Filter.with(Profile.Name).equal(name));
        return this;
    }
}
