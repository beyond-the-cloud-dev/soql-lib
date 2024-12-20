public with sharing class SOQL_UserCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_UserCache query() {
        return new SOQL_UserCache();
    }

    private SOQL_UserCache() {
        super(User.SObjectType);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(User.SObjectType).whereAre(SOQL.Filter.id().equal(UserInfo.getUserId()));
    }

    public override StorageType cacheIn() {
        return StorageType.SESSION_CACHE;
    }

    public override List<SObjectField> cachedBy() {
        return new List<SObjectField>{ User.Id, User.Username };
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ User.Id, User.Username, User.Name, User.Country };
    }

    public User byId(Id userId) {
        whereAre(SOQLCache.Filter.with(User.Id).equal(userId));
        return (User) toObject();
    }
}
