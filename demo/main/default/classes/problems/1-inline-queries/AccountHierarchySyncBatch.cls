public with sharing class AccountHierarchySyncBatch implements Database.Batchable<SObject> {
    private final Id parentId;

    public AccountHierarchySyncBatch(Id parentId) {
        this.parentId = parentId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, Name, Type FROM Account WHERE ParentId = :parentId]);
    }

    public void execute(Database.BatchableContext context, List<SObject> childAccounts) {
        update childAccounts;
    }

    public void finish(Database.BatchableContext context) {
    }
}
