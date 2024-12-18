public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQL.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        // default settings
        with(Profile.Id, Profile.Name);
    }

    public override SOQLCache.Storage getStorage() {
        return SOQLCache.Storage.ORG_CACHE;
    }
}

SOQL_ProfileCache.query().preview();
