public with sharing class SOQL_ProfileCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_ProfileCache query() {
        return new SOQL_ProfileCache();
    }

    private SOQL_ProfileCache() {
        super(Profile.SObjectType);
        cacheInOrgCache();
        //initialQuery(SOQL.of(Profile.SObjectType).systemMode().withoutSharing());
        // cachedFields(new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType });
    }

    // public override SOQL.Queryable initialQuery() {
    //     return SOQL.of(Profile.SObjectType).systemMode().withoutSharing();
    // }

    // public override List<SObjectField> cachedFields() {
    //     return new List<SObjectField>{ Profile.Id, Profile.Name, Profile.UserType };
    // }

    public Profile byName(String name) {
        return (Profile) whereEqual(Profile.Name, name).toObject();
    }
}

// SOQL_ProfileCache.query().byName('sys admin').cachedFields(new List<SObjectField>{ Profile.Licecense });


// Composition over inheritance

// SOQLCache.of(Profile.SObjectType)
//     .with(Profile.Id)
//     .whereAre(Profile.Name, 'Sys Admin')
//     .toObject();

/*
1. Unit Test w libie łatwiejsze
2.
*/
