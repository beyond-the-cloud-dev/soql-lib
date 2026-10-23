@IsTest
private class SecureByDefaultTest {
    private static final String MINIMUM_ACCESS_PROFILE = 'Minimum Access - Salesforce';

    @IsTest
    static void userModeBlocksUserWithoutAccountAccess() {
        insert new Account(Name = 'Acme');
        User restrictedUser = createMinimumAccessUser();

        System.runAs(restrictedUser) {
            try {
                SOQL.of(Account.SObjectType).with(Account.Id, Account.Name).toList();
                Assert.fail('User mode should block a user without access to Account.');
            } catch (QueryException e) {
                Assert.isNotNull(e.getMessage());
            }
        }
    }

    @IsTest
    static void systemModeReturnsRowsForUserWithoutAccountAccess() {
        insert new Account(Name = 'Acme');
        User restrictedUser = createMinimumAccessUser();

        System.runAs(restrictedUser) {
            List<Account> accounts = SOQL.of(Account.SObjectType)
                .with(Account.Id, Account.Name)
                .systemMode()
                .withoutSharing()
                .toList();

            Assert.areEqual(1, accounts.size());
        }
    }

    private static User createMinimumAccessUser() {
        Id profileId = SOQL.of(Profile.SObjectType)
            .whereAre(SOQL.Filter.with(Profile.Name).equal(MINIMUM_ACCESS_PROFILE))
            .systemMode()
            .toId();

        User restrictedUser = new User(
            LastName = 'Restricted',
            Alias = 'restrict',
            Email = 'restricted@example.com',
            Username = 'restricted@example.com.' + Datetime.now().getTime(),
            ProfileId = profileId,
            TimeZoneSidKey = 'Europe/Warsaw',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert restrictedUser;
        return restrictedUser;
    }
}
