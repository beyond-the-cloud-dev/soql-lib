public with sharing class PerformanceReport {
    private String query;
    private DateTime timestamp;
    private Decimal referenceStartTime;
    private Decimal referenceEndTime;
    private Decimal startTime;
    private Decimal endTime;
    private Integer heapSizeStart = 0;
    private Integer heapSizeEnd = 0;

    PerformanceResult result = new PerformanceResult();

    public PerformanceReport(String query) {
        this.query = query;
        this.timestamp = DateTime.now();
    }

    public PerformanceReport markReferenceStartTime() {
        this.referenceStartTime = Limits.getCpuTime();
        return this;
    }

    public PerformanceReport markReferenceEndTime() {
        this.referenceEndTime = Limits.getCpuTime();
        return this;
    }

    public PerformanceReport measureReferenceLoopCpuTime(Integer iterations) {
        this.markReferenceStartTime();
        for (Integer i = 0; i < iterations; i++) {}
        this.markReferenceEndTime();
        return this;
    }

    public PerformanceReport markTargetStartTime() {
        this.startTime = Limits.getCpuTime();
        return this;
    }

    public PerformanceReport markTargetEndTime() {
        this.endTime = Limits.getCpuTime();
        return this;
    }

    public PerformanceReport startHeapSizeMeasurement() {
        this.heapSizeStart = Limits.getHeapSize();
        return this;
    }

    public PerformanceReport endHeapSizeMeasurement() {
        this.heapSizeEnd = Limits.getHeapSize();
        return this;
    }

    public void report(Integer iterations) {
        this.calculateResult(iterations);   

        System.debug('====================================================================');
        System.debug('Query: ' + this.query);
        System.debug('====================================================================');
        System.debug('Timestamp: ' + this.timestamp);   
        System.debug('CPU Time Iterations: ' + iterations);
        System.debug('----------------------------------------------');
        System.debug('Total Reference CPU Time: ' + this.result.singleReferenceOperationInMicroseconds + 'ms');
        System.debug('Per Operation Reference CPU Time: ' + this.result.singleReferenceOperationInMicroseconds + 'ms');
        System.debug('Total Target CPU Time: ' + this.result.totalTime + 'ms or ' + this.result.totalTime / 1000 + 's for ' + iterations + ' iterations');
        System.debug('Per Operation Target CPU Time: ' + this.result.singleTargetOperationInMicroseconds + 'ms');
        System.debug('----------------------------------------------');
        System.debug('Per Operation Benchmark Results: ' + this.result.singleOperationInMicroseconds + 'ms');
        System.debug('----------------------------------------------');
        System.debug('Memory Iterations: ' + iterations);
        System.debug('Heap Size Start: ' + this.heapSizeStart + ' bytes');
        System.debug('Heap Size End: ' + this.heapSizeEnd + ' bytes');
        System.debug('Memory Used: ' + this.result.memoryUsed + ' bytes or ' + this.result.memoryUsed / 1024 + ' KB');
        System.debug('Memory Used per operation: ' + this.result.memoryUsed / iterations + ' bytes');
        System.debug('==============================================');
    }

    public void generateCSV(Integer iterations) {
        this.calculateResult(iterations);

        List<String> csvLines = new List<String>();

        csvLines.add('Query, Timestamp, Iterations, Total Time (ms), Per Operation Target CPU Time (ms), Memory Used (bytes), Memory Used per Operation (bytes)');

        csvLines.add(String.join(new List<String>{
            '"' + this.query + '"',
            '"' + this.result.timestamp.format('yyyy-MM-dd HH:mm:ss') + '"',
            String.valueOf(iterations),
            String.valueOf(this.result.totalTime),
            String.valueOf(this.result.singleTargetOperationInMicroseconds),
            String.valueOf(this.result.memoryUsed),
            String.valueOf(this.result.memoryUsedPerOperation)
        }, ','));
        
        System.debug(String.join(csvLines, '\n'));
    }

    private void calculateResult(Integer iterations) {
        Decimal referenceDuration = this.referenceEndTime - this.referenceStartTime;
        Decimal targetDuration = this.endTime - this.startTime;

        this.result.totalTime = targetDuration - referenceDuration;
        this.result.totalTime.setScale(2);

        this.result.singleOperationInMicroseconds = this.result.totalTime;
        this.result.singleOperationInMicroseconds /= iterations;
        this.result.singleOperationInMicroseconds.setScale(2);

        this.result.singleReferenceOperationInMicroseconds = referenceDuration;
        this.result.singleReferenceOperationInMicroseconds /= iterations;
        this.result.singleReferenceOperationInMicroseconds.setScale(2);

        this.result.singleTargetOperationInMicroseconds = targetDuration;
        this.result.singleTargetOperationInMicroseconds /= iterations;
        this.result.singleTargetOperationInMicroseconds.setScale(2);
        
        this.result.memoryUsed = this.heapSizeEnd - this.heapSizeStart;
        this.result.memoryUsedPerOperation = this.result.memoryUsed / iterations;
        this.result.memoryUsedPerOperation.setScale(2);

        this.result.timestamp = DateTime.now();
    }

    private class PerformanceResult {
        public String testName;
        public Integer iterations;
        public Decimal totalTime;
        public Decimal singleOperationInMicroseconds;
        public Decimal singleReferenceOperationInMicroseconds;
        public Decimal singleTargetOperationInMicroseconds;
        public Decimal memoryUsed;
        public Decimal memoryUsedPerOperation;
        public DateTime timestamp;
    }
}