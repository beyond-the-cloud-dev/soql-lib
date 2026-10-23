@IsTest
private class LeadSourceReportTest {
    @IsTest
    static void countLeadsBySource() {
        SOQL.mock('LeadSourceReport.countLeadsBySource').thenReturn(new List<Map<String, Object>>{
            new Map<String, Object>{ 'LeadSource' => 'Web', 'total' => 10 },
            new Map<String, Object>{ 'LeadSource' => 'Phone', 'total' => 5 }
        });

        Test.startTest();
        Map<String, Integer> result = LeadSourceReport.countLeadsBySource();
        Test.stopTest();

        Assert.areEqual(10, result.get('Web'));
        Assert.areEqual(5, result.get('Phone'));
    }
}
