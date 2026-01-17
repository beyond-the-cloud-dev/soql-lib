public without sharing class SOQL_CachedUser extends SOQLCache implements SOQLCache.Selector {
    public static SOQL_CachedUser query() {
        return new SOQL_CachedUser();
    }

    private SOQL_CachedUser() {
        super(User.SObjectType);
        cacheInSessionCache();
        with(User.Id, User.Username, User.Name, User.Country);
    }

    public override SOQL.Queryable initialQuery() {
        return SOQL.of(User.SObjectType).whereAre(SOQL.Filter.id().equal(UserInfo.getUserId()));
    }

    public override List<SObjectField> additionalAllowedConditionFields() {
        return new List<SObjectField>{ User.Username };
    }

    public SOQL_CachedUser byUsername(String username) {
        whereEqual(User.Username, username);
        return this;
    }
}
