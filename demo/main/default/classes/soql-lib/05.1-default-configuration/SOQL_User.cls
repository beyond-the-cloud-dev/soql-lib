public inherited sharing class SOQL_User extends SOQL implements SOQL.Selector {
    public static SOQL_User query() {
        return new SOQL_User();
    }

    private SOQL_User() {
        super(User.SObjectType);
        with(User.Id, User.Name, User.Email);
        // master condition: no query through this selector returns inactive users
        whereAre(Filter.with(User.IsActive).isTrue());
    }
}
