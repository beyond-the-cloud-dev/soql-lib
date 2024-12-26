public with sharing class SOQL_UserCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_UserCache query() {
        return new SOQL_UserCache();
    }

    private SOQL_UserCache() {
        super(User.SObjectType);
        cacheInSessionCache();
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(User.SObjectType).whereAre(SOQL.Filter.id().equal(UserInfo.getUserId()));
    }

    public override List<SObjectField> cachedFields() {
        return new List<SObjectField>{ User.Id, User.Username, User.Name, User.Country };
    }

    public User byUsername(String username) {
        return (User) whereEqual(User.Username, username).toObject();
    }
}
