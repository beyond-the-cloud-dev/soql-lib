/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * v6.0.1
 *
 * PMD False Positives:
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class SOQLEvaluator {
    public static SObjectEvaluable of(List<SObject> staticQueryRecords) {
        return new SObjectEvaluator(staticQueryRecords);
    }

    public interface SObjectEvaluable {
        // FIELD-LEVEL SECURITY
        SObjectEvaluable stripInaccessible();
        SObjectEvaluable stripInaccessible(AccessType accessType);
        // MOCKING
        SObjectEvaluable mockId(String mockId);
        // RESULT
        Id toId();
        Set<Id> toIds();
        Set<Id> toIdsOf(SObjectField field);
        Set<Id> toIdsOf(String relationshipName, SObjectField field);
        Boolean doExist();
        Object toValueOf(SObjectField fieldToExtract);
        Set<String> toValuesOf(SObjectField fieldToExtract);
        SObject toObject();
        List<SObject> toList();
        Map<Id, SObject> toMap();
        Map<String, SObject> toMap(SObjectField keyField);
        Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField);
        Map<String, String> toMap(SObjectField keyField, SObjectField valueField);
        Map<String, List<SObject>> toAggregatedMap(SObjectField keyField);
        Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField);
        Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField);
    }

    public interface Mockable {
        // SObject
        Mockable thenReturn(SObject record);
        Mockable thenReturn(List<SObject> records);
    }

    @TestVisible
    private static Mockable mock(String mockId) {
        if (!SOQLEvaluator.queryIdToMock.containsKey(mockId)) {
            SOQLEvaluator.queryIdToMock.put(mockId, new List<SoqlMock>());
        }
        SOQLEvaluator.queryIdToMock.get(mockId).add(new SoqlMock());
        return SOQLEvaluator.queryIdToMock.get(mockId).get(SOQLEvaluator.queryIdToMock.get(mockId).size() - 1);
    }

    // Implementation

    private static Map<String, List<SoqlMock>> queryIdToMock = new Map<String, List<SoqlMock>>();

    private class SObjectEvaluator implements SObjectEvaluable {
        private List<SObject> records;
        private AccessType access;
        private SOQL.Converter converter;
        private List<SoqlMock> mocks = new List<SoqlMock>();

        public SObjectEvaluator(List<SObject> records) {
            this.records = records;
            this.converter = new SOQL.Converter(records.getSObjectType().toString());
        }

        public SObjectEvaluable mockId(String mockId) {
            this.mocks = SOQLEvaluator.queryIdToMock.get(mockId) ?? new List<SoqlMock>();
            return this;
        }

        public SObjectEvaluable stripInaccessible() {
            return this.stripInaccessible(AccessType.READABLE);
        }

        public SObjectEvaluable stripInaccessible(AccessType accessType) {
            this.access = accessType;
            return this;
        }

        public Id toId() {
            return this.toObject()?.Id;
        }

        public Set<Id> toIds() {
            return new Map<Id, SObject>(this.toList()).keySet();
        }

        public Set<Id> toIdsOf(SObjectField field) {
            return this.converter.transform(this.toList()).toIdsOf(field);
        }

        public Set<Id> toIdsOf(String relationshipName, SObjectField field) {
            return this.converter.transform(this.toList()).toIdsOf(relationshipName, field);
        }

        public Boolean doExist() {
            return !this.toList().isEmpty();
        }

        public Object toValueOf(SObjectField fieldToExtract) {
            return this.toObject()?.get(fieldToExtract);
        }

        public Set<String> toValuesOf(SObjectField fieldToExtract) {
            return this.converter.transform(this.toList()).toValuesOf(fieldToExtract);
        }

        public SObject toObject() {
            List<SObject> records = this.toList();

            if (records.isEmpty()) {
                return null; // handle: List has no rows for assignment to SObject
            }

            if (records.size() > 1) {
                throw new QueryException('List has more than 1 row for assignment to SObject');
            }

            return records[0];
        }

        public List<SObject> toList() {
            if (!this.mocks.isEmpty()) {
                return this.getMockedListProxy();
            }

            if (this.access == null) {
                return this.records;
            }

            return System.Security.stripInaccessible(this.access, this.records).getRecords();
        }

        private List<SObject> getMockedListProxy() {
            if (this.mocks.size() == 1) {
                return this.mocks[0].sObjectMock.get();
            }
            return this.mocks.remove(0).sObjectMock.get();
        }

        public Map<Id, SObject> toMap() {
            return this.converter.transform(this.toList()).toMap();
        }

        public Map<String, SObject> toMap(SObjectField keyField) {
            return this.converter.transform(this.toList()).toMap(keyField);
        }

        public Map<String, SObject> toMap(String relationshipName, SObjectField targetKeyField) {
            return this.converter.transform(this.toList()).toMap(relationshipName, targetKeyField);
        }

        public Map<String, String> toMap(SObjectField keyField, SObjectField valueField) {
            return this.converter.transform(this.toList()).toMap(keyField, valueField);
        }

        public Map<String, List<SObject>> toAggregatedMap(SObjectField keyField) {
            return this.converter.transform(this.toList()).toAggregatedMap(keyField);
        }

        public Map<String, List<SObject>> toAggregatedMap(String relationshipName, SObjectField targetKeyField) {
            return this.converter.transform(this.toList()).toAggregatedMap(relationshipName, targetKeyField);
        }

        public Map<String, List<String>> toAggregatedMap(SObjectField keyField, SObjectField valueField) {
            return this.converter.transform(this.toList()).toAggregatedMap(keyField, valueField);
        }
    }

    public class SoqlMock implements Mockable {
        public SObjectMock sObjectMock = new SObjectMock();

        public Mockable thenReturn(SObject record) {
            this.sObjectMock.add(record);
            return this;
        }

        public Mockable thenReturn(List<SObject> records) {
            this.sObjectMock.add(records);
            return this;
        }
    }

    public class SObjectMock {
        private List<SObject> mockedRecords = new List<SObject>();

        public void add(SObject record) {
            this.mockedRecords.add(record);
        }

        public void add(List<SObject> records) {
            this.mockedRecords.addAll(records);
        }

        public List<SObject> get() {
            if (!this.mockedRecords.isEmpty()) {
                this.addIdToMockedRecords();
            }

            return this.mockedRecords;
        }

        private void addIdToMockedRecords() { // Id is always added to mirror standard SOQL behavior
            SObjectType sObjectType = this.mockedRecords[0].getSObjectType();
            String sObjectPrefix = sObjectType.getDescribe().getKeyPrefix();

            for (SObject record : this.mockedRecords) {
                record.put('Id', record?.Id ?? SOQL.IdGenerator.get(sObjectPrefix));
            }
        }
    }
}
