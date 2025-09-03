/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/cache-manager/blob/main/LICENSE)
 *
 * PMD False Positives:
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - PropertyNamingConventions: It was intentional to make the lib more fluent and readable
 * - FieldNamingConventions: It was intentional to make the lib more fluent and readable
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.PropertyNamingConventions,PMD.FieldNamingConventions')
public with sharing class CacheManager {
	public interface Cacheable {
		Boolean contains(String key);
		Set<String> getKeys();
		Object get(String key);
		void put(String key, Object value);
		void remove(String key);
	}

	public final static Cacheable ApexTransaction = new ApexTransactionCache();

	public final static Cacheable SOQLOrgCache {
		get { return getOrgCache('SOQL'); }
	}

	public final static Cacheable SOQLSessionCache {
		get { return getSessionCache('SOQL'); }
	}

	// Implementation

	private enum CacheType { ORG, SESSION }

	private final static Map<CacheType, Map<String, Cacheable>> CACHE_MAP = new Map<CacheType, Map<String, Cacheable>>{
		CacheType.ORG => new Map<String, Cacheable>(),
		CacheType.SESSION => new Map<String, Cacheable>()
	};

	private static Cacheable getOrgCache(String partitionName) {
		if (!CACHE_MAP.get(CacheType.ORG).containsKey(partitionName)) {
			CACHE_MAP.get(CacheType.ORG).put(partitionName, new OrgPlatformCache(partitionName));
		}
		return CACHE_MAP.get(CacheType.ORG).get(partitionName);
	}

	private static Cacheable getSessionCache(String partitionName) {
		if (!CACHE_MAP.get(CacheType.SESSION).containsKey(partitionName)) {
			CACHE_MAP.get(CacheType.SESSION).put(partitionName, new SessionPlatformCache(partitionName));
		}
		return CACHE_MAP.get(CacheType.SESSION).get(partitionName);
	}

	private static void validateKey(String key) {
		if (!Pattern.compile('^[a-zA-Z0-9]+$').matcher(key).matches()) {
			throw new IllegalArgumentException('Key must be alphanumeric, received key: ' + key);
		}
	}

	private class ApexTransactionCache implements Cacheable {
		private final Map<String, Object> TRANSACTION_CACHE = new Map<String, Object>();

		public Boolean contains(String key) {
			return this.TRANSACTION_CACHE.containsKey(key);
		}

		public Set<String> getKeys() {
			return TRANSACTION_CACHE.keySet();
		}

		public Object get(String key) {
			return this.TRANSACTION_CACHE.get(key);
		}

		public void put(String key, Object value) {
			validateKey(key);
			this.TRANSACTION_CACHE.put(key, value);
		}

		public void remove(String key) {
			this.TRANSACTION_CACHE.remove(key);
		}
	}

	private abstract class PlatformCache implements Cacheable {
		private Cache.Partition platformCachePartition;

		public PlatformCache(String partitionName) {
			this.platformCachePartition = getPartition(partitionName);
		}

		protected abstract Cache.Partition getPartition(String partitionName);

		public Boolean contains(String key) {
			return this.platformCachePartition.contains(key);
		}

		public Set<String> getKeys() {
			return this.platformCachePartition.getKeys();
		}

		public Object get(String key) {
			return this.platformCachePartition.get(key);
		}

		public void remove(String key) {
			this.platformCachePartition.remove(key);
		}

		public void put(String key, Object value) {
			validateKey(key);
			this.platformCachePartition.put(key, value);
		}
	}

	private class OrgPlatformCache extends PlatformCache {
		public OrgPlatformCache(String partitionName) {
			super(partitionName);
		}

		public override Cache.Partition getPartition(String partitionName) {
			return Cache.Org.getPartition(partitionName);
		}
	}

	private class SessionPlatformCache extends PlatformCache {
		public SessionPlatformCache(String partitionName) {
			super(partitionName);
		}

		public override Cache.Partition getPartition(String partitionName) {
			return Cache.Session.getPartition(partitionName);
		}
	}
}
