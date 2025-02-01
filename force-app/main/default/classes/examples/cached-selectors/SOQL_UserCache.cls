public with sharing class SOQL_UserCache extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_UserCache query() {
        return new SOQL_UserCache();
    }

    private SOQL_UserCache() {
        super(User.SObjectType);
        cacheInSessionCache();
        with(User.Id, User.Username, User.Name, User.Country);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(User.SObjectType).whereAre(SOQL.Filter.id().equal(UserInfo.getUserId()));
    }

    public SOQL_UserCache byUsername(String username) {
        whereEqual(User.Username, username);
        return this;
    }
}
