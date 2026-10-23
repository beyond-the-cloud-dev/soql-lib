public class Application {
    public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type>{
            Opportunity.SObjectType => OpportunitiesSelector.class,
            PortalUser__c.SObjectType => PortalUserSelector.class
        }
    );
}
