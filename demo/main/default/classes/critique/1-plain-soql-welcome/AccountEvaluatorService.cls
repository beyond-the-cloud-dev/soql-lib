public with sharing class AccountEvaluatorService {
    public static Set<Id> getAccountIds(String industry) {
        return SOQLEvaluator.of([SELECT Id FROM Account WHERE Industry = :industry])
            .mockId('AccountEvaluatorService.getAccountIds')
            .toIds();
    }

    public static Set<String> getAccountNames() {
        return SOQLEvaluator.of([SELECT Id, Name FROM Account]).toValuesOf(Account.Name);
    }
}
