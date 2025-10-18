/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * v6.1.0
 *
 * PMD False Positives:
 * - ExcessivePublicCount: It is a library class and exposes all necessary methods to construct a query
 * - ExcessiveClassLength: It is a library and we tried to put everything into ONE class
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - PropertyNamingConventions: It was intentional to make the lib more fluent and readable
 * - FieldDeclarationsShouldBeAtStart: Developer who uses lib should see what's important at start
 * - ApexDoc: Variable names are self-documented.
 * - ExcessiveParameterList: Make methods similar to native SOQL
**/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.ExcessiveClassLength,PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.PropertyNamingConventions,PMD.FieldDeclarationsShouldBeAtStart,PMD.ApexDoc,PMD.ExcessiveParameterList')
public virtual inherited sharing class SOQLCache implements Cacheable {
	public interface Selector {
		Cacheable query();
	}

	public static Cacheable of(SObjectType ofObject) {
		return new SOQLCache(ofObject);
	}

	public static Cacheable of(String ofObject) {
		return new SOQLCache(ofObject);
	}

	public interface Cacheable {
		// CONFIG
		Cacheable cacheInApexTransaction();
		Cacheable cacheInOrgCache();
		Cacheable cacheInSessionCache();
		Cacheable maxHoursWithoutRefresh(Integer hours);
		Cacheable allowFilteringByNonUniqueFields();
		Cacheable allowQueryWithoutConditions();
		// SELECT
		Cacheable with(SObjectField field);
		Cacheable with(SObjectField field1, SObjectField field2);
		Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3);
		Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
		Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
		Cacheable with(List<SObjectField> fields);
		Cacheable with(String fields);
		Cacheable with(String relationshipName, SObjectField field);
		Cacheable with(String relationshipName, SObjectField field1, SObjectField field2);
		Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3);
		Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4);
		Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5);
		Cacheable with(String relationshipName, Iterable<SObjectField> fields);
		// WHERE
		Cacheable whereEqual(SObjectField field, Object value);
		Cacheable whereEqual(String field, Object value);
		// FIELD-LEVEL SECURITY
		Cacheable stripInaccessible();
		Cacheable stripInaccessible(AccessType accessType);
		// MOCKING
		Cacheable mockId(String queryIdentifier);
		// DEBUGGING
		Cacheable preview();
		// PREDEFINED
		Cacheable byId(SObject record);
		Cacheable byId(Id recordId);
		// RESULT
		Id toId();
		Id toIdOf(SObjectField field);
		Boolean doExist();
		SObject toObject();
		Object toValueOf(SObjectField fieldToExtract);
	}

	protected virtual SOQL.Queryable initialQuery() {
		return null;
	}

	public virtual List<SObjectField> additionalAllowedConditionFields() {
		return new List<SObjectField>();
	}

	// Mocking

	public interface Mockable {
		// SObject
		void thenReturn(SObject record);
	}

	@TestVisible
	private static Mockable mock(String mockId) {
		if (!SOQLCache.queryIdToMock.containsKey(mockId)) {
			SOQLCache.queryIdToMock.put(mockId, new List<SoqlMock>());
		}
		SOQLCache.queryIdToMock.get(mockId).add(new SoqlMock());
		return SOQLCache.queryIdToMock.get(mockId).get(SOQLCache.queryIdToMock.get(mockId).size() - 1);
	}

	public static void removeFromCache(List<SObject> records) {
		if (records.isEmpty()) {
			return;
		}

		String ofObject = records[0].getSObjectType().toString();
		CacheStorageProxy proxy = new CacheStorageProxy(ofObject);

		// Record deletion will trigger an automatic cache refresh when the query is executed.
		proxy.apexTransaction().removeRecordsFromCache(records);
		proxy.orgCache().removeRecordsFromCache(records);
		proxy.sessionCache().removeRecordsFromCache(records);
	}

	// Backward support

	@TestVisible  // deprecated
	private static void setMock(String mockId, SObject record) {
		SOQLCache.queryIdToMock.put(mockId, new List<SoqlMock>{ new SoqlMock() });
		SOQLCache.queryIdToMock.get(mockId).get(SOQLCache.queryIdToMock.get(mockId).size() - 1).thenReturn(record);
	}

	// Implementation

	private static Map<String, List<SoqlMock>> queryIdToMock = new Map<String, List<SoqlMock>>();

	private Executor executor;
	private Cache cache;

	public SOQL.Queryable initialQuery = null;
	public SOQL.Queryable currentQuery = null;

	protected SOQLCache(SObjectType ofObject) {
		this(ofObject.toString());
	}

	protected SOQLCache(String ofObject) {
		this.initialQuery = this.initialQuery()?.systemMode()?.withoutSharing();
		this.currentQuery = SOQL.of(ofObject).systemMode().withoutSharing();

		this.cache = new Cache(ofObject);
		this.cache.filterGroup.setAdditionalAllowedConditionFields(this.additionalAllowedConditionFields());
		this.executor = new Executor(this.currentQuery, this.cache);

		this.with('Id');
	}

	public Cacheable cacheInApexTransaction() {
		this.cache.storage.apexTransaction();
		return this;
	}

	public Cacheable cacheInOrgCache() {
		this.cache.storage.orgCache();
		return this;
	}

	public Cacheable cacheInSessionCache() {
		this.cache.storage.sessionCache();
		return this;
	}

	public Cacheable maxHoursWithoutRefresh(Integer hours) {
		this.cache.expiration.maxRecordAgeInHours(hours);
		return this;
	}

	public Cacheable allowFilteringByNonUniqueFields() {
		this.cache.filterGroup.allowFilteringByNonUniqueFields();
		return this;
	}

	public Cacheable allowQueryWithoutConditions() {
		this.cache.filterGroup.allowQueryWithoutConditions();
		return this;
	}

	public Cacheable with(SObjectField field) {
		this.initialQuery?.with(field);
		this.currentQuery.with(field);
		this.cache.fields.with(field);
		return this;
	}

	public Cacheable with(SObjectField field1, SObjectField field2) {
		return this.with(field1).with(field2);
	}

	public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3) {
		return this.with(field1, field2).with(field3);
	}

	public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
		return this.with(field1, field2, field3).with(field4);
	}

	public Cacheable with(SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
		return this.with(field1, field2, field3, field4).with(field5);
	}

	public Cacheable with(List<SObjectField> fields) {
		this.initialQuery?.with(fields);
		this.currentQuery.with(fields);
		this.cache.fields.with(fields);
		return this;
	}

	public Cacheable with(String fields) {
		this.initialQuery?.with(fields);
		this.currentQuery.with(fields);
		this.cache.fields.with(fields);
		return this;
	}

	public Cacheable with(String relationshipName, SObjectField field) {
		this.initialQuery?.with(relationshipName, field);
		this.currentQuery.with(relationshipName, field);
		this.cache.fields.with(relationshipName, field);
		return this;
	}

	public Cacheable with(String relationshipName, SObjectField field1, SObjectField field2) {
		return this.with(relationshipName, new List<SObjectField>{ field1, field2 });
	}

	public Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3) {
		return this.with(relationshipName, new List<SObjectField>{ field1, field2, field3 });
	}

	public Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4) {
		return this.with(relationshipName, new List<SObjectField>{ field1, field2, field3, field4 });
	}

	public Cacheable with(String relationshipName, SObjectField field1, SObjectField field2, SObjectField field3, SObjectField field4, SObjectField field5) {
		return this.with(relationshipName, new List<SObjectField>{ field1, field2, field3, field4, field5 });
	}

	public Cacheable with(String relationshipName, Iterable<SObjectField> fields) {
		this.initialQuery?.with(relationshipName, fields);
		this.currentQuery.with(relationshipName, fields);
		this.cache.fields.with(relationshipName, fields);
		return this;
	}

	public Cacheable whereEqual(SObjectField field, Object value) {
		return this.whereEqual(field.toString(), value);
	}

	public Cacheable whereEqual(String field, Object value) {
		this.with(field);
		this.cache.filterGroup.add(new CacheFilter().with(field).equal(value));
		this.currentQuery.whereAre(SOQL.Filter.with(field).equal(value));
		return this;
	}

	public Cacheable stripInaccessible() {
		return this.stripInaccessible(AccessType.READABLE);
	}

	public Cacheable stripInaccessible(AccessType accessType) {
		this.currentQuery.stripInaccessible(accessType);
		this.executor.stripInaccessible(accessType);
		return this;
	}

	public Cacheable mockId(String queryIdentifier) {
		this.currentQuery.mockId(queryIdentifier);
		this.executor.mock(queryIdToMock.get(queryIdentifier));
		return this;
	}

	public Cacheable preview() {
		this.currentQuery.preview();
		return this;
	}

	public Id toId() {
		return this.toObject()?.Id;
	}

	public Id toIdOf(SObjectField field) {
		return (Id) this.toObject()?.get(field);
	}

	public Boolean doExist() {
		return this.toObject() != null;
	}

	public Object toValueOf(SObjectField fieldToExtract) {
		this.with(fieldToExtract);
		return this.toObject()?.get(fieldToExtract);
	}

	public SObject toObject() {
		this.cache.filterGroup.validateIfQueryHasAtLeastOneCondition();
		this.executeInitialQuery();
		return this.executor.toObject();
	}

	private void executeInitialQuery() {
		if (this.cache.storage.hasCachedRecords() || this.initialQuery == null) {
			return;
		}
		this.cache.storage.putInitialRecordsToCache(this.initialQuery.toList());
	}

	public Cacheable byId(SObject record) {
		return byId(record.Id);
	}

	public Cacheable byId(Id recordId) {
		whereEqual('Id', recordId);
		return this;
	}

	private class CacheStorageProxy {
		private CacheManager.Cacheable storage = CacheManager.ApexTransaction;
		private String cacheKey;

		public CacheStorageProxy(String ofObject) {
			this.cacheKey = this.getAlphanumericKeyFromObjectApiName(ofObject);
		}

		private String getAlphanumericKeyFromObjectApiName(String ofObject) {
			return Pattern.compile('[^a-zA-Z0-9]').matcher(ofObject).replaceAll('');
		}

		public CacheStorageProxy apexTransaction() {
			this.storage = CacheManager.ApexTransaction;
			return this;
		}

		public CacheStorageProxy orgCache() {
			this.storage = CacheManager.SOQLOrgCache;
			return this;
		}

		public CacheStorageProxy sessionCache() {
			this.storage = CacheManager.SOQLSessionCache;
			return this;
		}

		public void putInitialRecordsToCache(List<SObject> records) {
			List<CacheItem> cacheRecords = new List<CacheItem>();

			for (SObject record : records) {
				cacheRecords.add(new CacheItem(record));
			}

			this.putRecordsToCache(cacheRecords);
		}

		public void putRecordsToCache(List<CacheItem> records) {
			this.storage.put(this.cacheKey, records);
		}

		public Boolean hasCachedRecords() {
			return this.storage.contains(this.cacheKey);
		}

		public List<CacheItem> getCachedRecords() {
			return (List<CacheItem>) (this.storage.get(this.cacheKey) ?? new List<CacheItem>());
		}

		public void addRecordsToCache(List<SObject> recordsToAdd) {
			List<CacheItem> allCachedRecords = getCachedRecords();

			for (SObject databaseRecord : recordsToAdd) {
				allCachedRecords.add(new CacheItem(databaseRecord));
			}

			putRecordsToCache(allCachedRecords);
		}

		public void updateRecordsInCache(List<SObject> recordsToUpdate) {
			List<CacheItem> allCachedRecords = getCachedRecords();

			Map<Id, SObject> updatedRecordsById = new Map<Id, SObject>(recordsToUpdate);

			for (CacheItem cachedRecord : allCachedRecords) {
				if (updatedRecordsById.containsKey(cachedRecord.id)) {
					cachedRecord.record = updatedRecordsById.get(cachedRecord.id);
					cachedRecord.cachedDate = System.now();
				}
			}

			putRecordsToCache(allCachedRecords);
		}

		public void removeRecordsFromCache(List<SObject> recordsToRemove) {
			Set<Id> recordsToRemoveIds = new Map<Id, SObject>(recordsToRemove).keySet();

			List<CacheItem> filteredCachedItems = new List<CacheItem>();

			for (CacheItem cachedRecord : getCachedRecords()) {
				if (!recordsToRemoveIds.contains(cachedRecord.id)) {
					filteredCachedItems.add(cachedRecord);
				}
			}

			putRecordsToCache(filteredCachedItems);
		}
	}

	private class Cache {
		public CacheFields fields;
		public CacheExpiration expiration;
		public CacheFilterGroup filterGroup;
		public CacheStorageProxy storage;

		public Cache(String ofObject) {
			this.filterGroup = new CacheFilterGroup(ofObject);
			this.storage = new CacheStorageProxy(ofObject);
			this.fields = new CacheFields();
			this.expiration = new CacheExpiration();
		}

		private List<CacheItem> cachedItemsThatMeetCriteria {
			get {
				if (this.cachedItemsThatMeetCriteria == null) {
					this.cachedItemsThatMeetCriteria = this.filterGroup.filter(this.storage.getCachedRecords());
				}
				return this.cachedItemsThatMeetCriteria;
			}
			private set;
		}

		public List<SObject> toList() {
			List<SObject> records = new List<SObject>();

			for (CacheItem cachedRecord : this.cachedItemsThatMeetCriteria) {
				records.add(cachedRecord.record);
			}

			return records;
		}

		public void save(List<SObject> databaseRecords) {
			if (this.isRecordMissingFromCache()) {
				storage.addRecordsToCache(databaseRecords);
			} else if (databaseRecords.isEmpty()) { // record does not exist in database anymore
				storage.removeRecordsFromCache(this.toList());
			} else if (this.areRequestedFieldsMissing() || this.areRecordsOutdated()) {
				storage.updateRecordsInCache(databaseRecords);
			}
		}

		public Boolean isRecordMissingFromCache() {
			return this.cachedItemsThatMeetCriteria.isEmpty();
		}

		public Boolean areRequestedFieldsMissing() {
			return !this.fields.haveAllRequestedFields(this.cachedItemsThatMeetCriteria);
		}

		public Boolean areRecordsOutdated() {
			return !this.expiration.areRecordsRecentEnough(this.cachedItemsThatMeetCriteria);
		}
	}

	@TestVisible
	private class CacheItem {
		public Id id;
		public Datetime cachedDate;
		public SObject record;

		public CacheItem(SObject record) {
			this.id = record.Id;
			this.cachedDate = System.now();
			this.record = record;
		}
	}

	private class CacheFilterGroup {
		private String ofObject;

		private List<CacheFilter> filters = new List<CacheFilter>();
		private List<String> additionalAllowedConditionFields = new List<String>();

		private Boolean allowFilteringByNonUniqueFields = false;
		private Boolean allowQueryWithoutConditions = false;

		public CacheFilterGroup(String ofObject) {
			this.ofObject = ofObject;
		}

		public void add(CacheFilter filter) {
			this.filters.add(filter);
		}

		public void setAdditionalAllowedConditionFields(List<SObjectField> additionalAllowedConditionFields) {
			for (SObjectField field : additionalAllowedConditionFields) {
				this.additionalAllowedConditionFields.add(field.toString());
			}
		}

		public void allowFilteringByNonUniqueFields() {
			this.allowFilteringByNonUniqueFields = true;
		}

		public void allowQueryWithoutConditions() {
			this.allowQueryWithoutConditions = true;
		}

		public void validateUniqueCondition(CacheFilter filter) {
			if (this.allowFilteringByNonUniqueFields) {
				return;
			}

			if (!(new List<String>{ 'Id', 'Name', 'DeveloperName' }.contains(filter.field) || this.additionalAllowedConditionFields.contains(filter.field) || this.isFieldUnique(filter.field))) {
				throw new SoqlCacheException('A cached query can be filtered only by Id, Name, DeveloperName, or a unique field. You can ignore this validation by calling allowFilteringByNonUniqueFields()');
			}
		}

		public void validateIfQueryHasAtLeastOneCondition() {
			if (!this.allowQueryWithoutConditions && this.filters.isEmpty()) {
				throw new SoqlCacheException('A condition is missing. Please provide a filter to retrieve the cached record. You can ignore this validation by calling allowQueryWithoutConditions()');
			}
		}

		private void validateConditions() {
			for (CacheFilter filter : this.filters) {
				this.validateUniqueCondition(filter);
			}
		}

		private Boolean isFieldUnique(String field) {
			return Schema.getGlobalDescribe().get(this.ofObject).getDescribe().fields.getMap().get(field).getDescribe().isUnique();
		}

		public List<CacheItem> filter(List<CacheItem> cachedItems) {
			this.validateConditions();

			List<CacheItem> cacheItemsThatMeetCriteria = new List<CacheItem>();

			for (CacheItem cacheItem : cachedItems) {
				Boolean isCachedItemsMatchingAllCriteria = true;

				for (CacheFilter filter : this.filters) {
					isCachedItemsMatchingAllCriteria &= filter.isMatching(cacheItem);
				}

				if (isCachedItemsMatchingAllCriteria) {
					cacheItemsThatMeetCriteria.add(cacheItem);
				}
			}

			return cacheItemsThatMeetCriteria;
		}
	}

	private class CacheFilter {
		public String field;
		private Object value;

		public CacheFilter with(String field) {
			this.field = field;
			return this;
		}

		public CacheFilter equal(Object value) {
			this.value = value;
			return this;
		}

		public Boolean isMatching(CacheItem cachedItem) {
			return cachedItem.record.get(this.field) == this.value;
		}
	}

	private class CacheFields {
		private Set<String> cachedFields = new Set<String>();
		private Set<String> cachedRelationshipFields = new Set<String>();

		public void with(String commaSeparatedFields) {
			for (String field : commaSeparatedFields.split(',')) {
				this.classifyField(field);
			}
		}

		private void classifyField(String field) {
			String trimmedField = field.trim();

			if (trimmedField.contains('.')) {
				this.cachedRelationshipFields.add(trimmedField);
			} else {
				this.cachedFields.add(trimmedField);
			}
		}

		public void with(SObjectField field) {
			this.cachedFields.add(field.toString());
		}

		public void with(List<SObjectField> fields) {
			for (SObjectField field : fields) {
				this.cachedFields.add(field.toString());
			}
		}

		public void with(String relationshipName, SObjectField field) {
			this.cachedRelationshipFields.add(relationshipName + '.' + field.toString());
		}

		public void with(String relationshipName, Iterable<SObjectField> fields) {
			for (SObjectField field : fields) {
				this.with(relationshipName, field);
			}
		}

		public Boolean haveAllRequestedFields(List<CacheItem> cachedItems) {
			for (CacheItem cachedItem : cachedItems) {
				if (!this.hasAllRequestedPlainFields(cachedItem.record) ||
					!this.hasAllRequestedRelationshipFields(cachedItem.record)) {
					return false;
				}
			}
			return true;
		}

		private Boolean hasAllRequestedPlainFields(SObject record) {
			for (String field : this.cachedFields) {
				if (!record.isSet(field)) {
					return false;
				}
			}

			return true;
		}

		private Boolean hasAllRequestedRelationshipFields(SObject record) {
			for (String relationship : this.cachedRelationshipFields) {
				if (!this.isRelationshipFieldSet(record, relationship)) {
					return false;
				}
			}

			return true;
		}

		private Boolean isRelationshipFieldSet(SObject record, String relationship) {
			List<String> relationshipPath = relationship.split('\\.');

			String targetField = relationshipPath.remove(relationshipPath.size() - 1);
			SObject targetRelationshipSObject = this.getTargetRelationshipSObject(record, relationshipPath);

			return targetRelationshipSObject == null ? false : targetRelationshipSObject.isSet(targetField);
		}

		private SObject getTargetRelationshipSObject(SObject record, List<String> relationshipPath) {
			SObject currentRecord = record;

			for (String relationshipField : relationshipPath) {
				try {
					currentRecord = currentRecord.getSObject(relationshipField);
				} catch (System.SObjectException e) {
					// Calling getSObject() on a SObject throws an exception if the field is not queried
					// We need to return null to avoid what means that the relationship field is not set
					return null;
				}
			}

			return currentRecord;
		}
	}

	private class CacheExpiration {
		private Integer maxRecordAgeInHours = 48;

		public void maxRecordAgeInHours(Integer hours) {
			this.maxRecordAgeInHours = hours;
		}

		public Boolean areRecordsRecentEnough(List<CacheItem> cachedItems) {
			for (CacheItem cachedItem : cachedItems) {
				if (!isRecentEnough(cachedItem)) {
					return false;
				}
			}

			return true;
		}

		public Boolean isRecentEnough(CacheItem cachedItem) {
			Decimal recordAgeInHoursSinceCached = (System.now().getTime() - cachedItem.cachedDate.getTime()) / 3600000;
			return recordAgeInHoursSinceCached <= this.maxRecordAgeInHours;
		}
	}

	public class SoqlMock implements Mockable {
		private List<SObject> mockedRecords = new List<SObject>();

		public void thenReturn(SObject record) {
			this.mockedRecords.add(record);
		}

		public List<SObject> getMockedResult() {
			return mockedRecords;
		}
	}

	private inherited sharing class Executor {
		private SOQL.Queryable currentQuery;
		private Cache cache;
		private AccessType accessType = null;
		private List<SoqlMock> mocks = new List<SoqlMock>();

		public Executor(SOQL.Queryable currentQuery, Cache cache) {
			this.currentQuery = currentQuery;
			this.cache = cache;
		}

		public void stripInaccessible(AccessType type) {
			this.accessType = type;
		}

		public void mock(List<SoqlMock> mocks) {
			this.mocks = mocks ?? new List<SoqlMock>();
		}

		public SObject toObject() {
			List<SObject> records = this.toList();

			if (records.isEmpty()) {
				return null;
			}

			if (records.size() > 1) {
				throw new QueryException('List has more than 1 row for assignment to SObject');
			}

			return records[0];
		}

		private List<SObject> toList() {
			if (!this.mocks.isEmpty()) {
				return this.getMockedList();
			}

			List<SObject> records = this.cache.toList();

			if (
				this.cache.isRecordMissingFromCache() ||
				this.cache.areRequestedFieldsMissing() ||
				this.cache.areRecordsOutdated()
			) {
				records = this.currentQuery.toList(); // SOQL query execution
				cache.save(records);
			}

			if (this.accessType == null) {
				return records;
			}

			return System.Security.stripInaccessible(this.accessType, records).getRecords();
		}

		private List<SObject> getMockedList() {
			if (this.mocks.size() == 1) {
				return this.mocks[0].getMockedResult();
			}
			return this.mocks.remove(0).getMockedResult();
		}
	}

	public class SoqlCacheException extends Exception {}
}
