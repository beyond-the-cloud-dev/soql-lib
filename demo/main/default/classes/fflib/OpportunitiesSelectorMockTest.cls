@IsTest
private class OpportunitiesSelectorMockTest {
    @IsTest
    static void returnsStubbedOpportunities() {
        List<Opportunity> testOppsList = new List<Opportunity>{
            new Opportunity(Id = fflib_IDGenerator.generate(Opportunity.SObjectType), Name = 'Test Opportunity')
        };
        Set<Id> testOppsSet = new Map<Id, Opportunity>(testOppsList).keySet();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector selectorMock = (IOpportunitiesSelector) mocks.mock(IOpportunitiesSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(selectorMock.selectByIdWithProducts(testOppsSet)).thenReturn(testOppsList);
        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);

        Test.startTest();
        IOpportunitiesSelector selector = (IOpportunitiesSelector) Application.Selector.newInstance(Opportunity.SObjectType);
        List<Opportunity> result = selector.selectByIdWithProducts(testOppsSet);
        Test.stopTest();

        Assert.areEqual(1, result.size());
    }
}
